#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base_temp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
work_root="$(mktemp -d "${base_temp%/}/nvime-package.XXXXXX")"

cleanup() {
    rm -rf "$work_root"
}
trap cleanup EXIT

version="${NVIME_RELEASE_VERSION:-${GITHUB_REF_NAME:-}}"
if [[ -z "$version" ]]; then
    version="$(git -C "$repo_root" describe --tags --always)"
fi

if [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    installed_nvim="$(nvim --version | head -n 1)"
    installed_nvim="${installed_nvim#NVIM v}"
    if [[ "${version%.*}" != "v$installed_nvim" ]]; then
        echo "Release tag $version does not match Neovim $installed_nvim from the CI environment." >&2
        exit 1
    fi
fi

os="${NVIME_PACKAGE_OS:-$(uname -s)}"
arch="${NVIME_PACKAGE_ARCH:-$(uname -m)}"

case "$os" in
    Linux)
        platform="linux"
        ;;
    Darwin)
        platform="macos"
        ;;
    *)
        echo "Unsupported operating system: $os" >&2
        exit 1
        ;;
esac

package_version="${version#v}"
package_version="${package_version//-/.}"
if [[ ! "$package_version" =~ ^[0-9] ]]; then
    package_version="0.0.0+${package_version}"
fi

case "$arch" in
    x86_64)
        arch_label="x86_64"
        deb_arch="amd64"
        rpm_arch="x86_64"
        ;;
    aarch64|arm64)
        arch_label="arm64"
        deb_arch="arm64"
        rpm_arch="aarch64"
        ;;
    *)
        echo "Unsupported architecture: $arch" >&2
        exit 1
        ;;
esac

# Native libraries cannot be cross-packaged by merely overriding the label.
case "$(uname -s)/$(uname -m)/$platform/$arch_label" in
    Linux/x86_64/linux/x86_64|Linux/aarch64/linux/arm64|Linux/arm64/linux/arm64|Darwin/arm64/macos/arm64) ;;
    *) echo "Native bundles must be built on a matching supported host." >&2; exit 1 ;;
esac

bundle_name="nvime-${version}-${platform}-${arch_label}"
artifact_root="${ARTIFACT_OUTPUT_DIR:-${base_temp%/}/nvime-artifacts}"

if [[ -n "${NVIME_PACKAGE_FORMATS:-}" ]]; then
    read -r -a package_formats <<<"${NVIME_PACKAGE_FORMATS//,/ }"
elif [[ "$platform" == "linux" ]]; then
    package_formats=("tar.gz" "deb" "rpm")
else
    package_formats=("dmg")
fi

created_paths=()

export HOME="$work_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="${NVIME_XDG_DATA_HOME:-$work_root/data}"
export XDG_STATE_HOME="$work_root/state"
export XDG_CACHE_HOME="${NVIME_XDG_CACHE_HOME:-$work_root/cache}"
unset VIMINIT EXINIT NVIM_APPNAME

config_root="$XDG_CONFIG_HOME/nvim"
data_root="$XDG_DATA_HOME/nvim"
bundle_root="$work_root/$bundle_name"
payload_root="$bundle_root/payload"
payload_config_root="$payload_root/config/nvim"
payload_data_root="$payload_root/data/nvim"

run_headless_nvim() {
    nvim --headless \
        '+lua if vim.v.errmsg ~= "" then vim.api.nvim_err_writeln(vim.v.errmsg); vim.cmd("cquit") end' \
        '+qa'
}

mkdir -p \
    "$artifact_root" \
    "$config_root" \
    "$data_root" \
    "$XDG_STATE_HOME" \
    "$XDG_CACHE_HOME" \
    "$payload_config_root" \
    "$payload_data_root"

cp -R "$repo_root/." "$config_root"

echo "Bootstrapping packaged config in $config_root"
NVIME_SKIP_BLINK_NATIVE=1 run_headless_nvim
python3 "$repo_root/scripts/ci-blink.py" prepare \
    --lock "$repo_root/nvim-pack-lock.json" \
    --data-root "$data_root" \
    --manifest "$work_root/blink-native.json"

rsync -a \
    --exclude='.git/' \
    --exclude='.github/' \
    --exclude='node_modules/' \
    --exclude='scripts/' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='arch-install.sh' \
    --exclude='nvim.log' \
    "$config_root/" "$payload_config_root/"

if [[ -d "$data_root" ]]; then
    rsync -a \
        --exclude='site/pack/core/opt/blink.cmp/target/' \
        --exclude='site/pack/core/opt/blink.pairs/lib/libblink_pairs_parser*' \
        --exclude='site/pack/core/opt/blink.pairs/target/' \
        "$data_root/" "$payload_data_root/"
fi

# Keep the broad build-cache exclusions above, then add back ONLY verified
# runtime libraries and cmp's version/checksum metadata (not Cargo build trees).
python3 "$repo_root/scripts/ci-blink.py" stage \
    --data-root "$data_root" \
    --manifest "$work_root/blink-native.json" \
    --destination "$payload_data_root"
cp "$work_root/blink-native.json" "$bundle_root/blink-native.json"

cp "$repo_root/scripts/install-bundle.sh" "$bundle_root/install.sh"
chmod +x "$bundle_root/install.sh"

cat > "$bundle_root/README.txt" <<EOF
NVIME ${version}

Contents:
- install.sh: installs the bundled config and downloaded plugins
- payload/: the packaged Neovim config, vim.pack plugins and native Blink libraries
- blink-native.json: required platform, releases, revisions and verified asset hashes

Blink native libraries are preinstalled; no Rust compiler or first-start download
is needed. Git and Neovim 0.12+ are still required. Linux bundles target glibc.

Install:
1. Open a terminal in this directory.
2. Run ./install.sh
3. Start Neovim with: nvim
EOF

build_tarball() {
    local output_path="$artifact_root/${bundle_name}.tar.gz"

    tar -C "$work_root" -czf "$output_path" "$bundle_name"
    created_paths+=("$output_path")
    echo "Created package: $output_path"
}

build_dmg() {
    local output_path="$artifact_root/${bundle_name}.dmg"

    if ! command -v hdiutil >/dev/null 2>&1; then
        echo "hdiutil is required to build macOS DMG packages" >&2
        exit 1
    fi

    hdiutil create \
        -volname "NVIME ${version}" \
        -srcfolder "$bundle_root" \
        -ov \
        -format UDZO \
        "$output_path" >/dev/null

    created_paths+=("$output_path")
    echo "Created package: $output_path"
}

populate_system_package_root() {
    local package_root="$1"

    mkdir -p \
        "$package_root/usr/bin" \
        "$package_root/usr/share/doc/nvime" \
        "$package_root/usr/share/nvime"

    rsync -a "$bundle_root/payload" "$package_root/usr/share/nvime/"
    install -m 0755 "$bundle_root/install.sh" "$package_root/usr/share/nvime/install.sh"
    install -m 0644 "$bundle_root/blink-native.json" "$package_root/usr/share/nvime/blink-native.json"
    install -m 0644 "$bundle_root/README.txt" "$package_root/usr/share/doc/nvime/README.txt"

    cat > "$package_root/usr/bin/nvime-install" <<'EOF'
#!/usr/bin/env bash
exec /usr/share/nvime/install.sh "$@"
EOF
    chmod +x "$package_root/usr/bin/nvime-install"
}

build_deb() {
    local deb_root="$work_root/deb-root"
    local output_path="$artifact_root/${bundle_name}.deb"
    local installed_size

    if [[ "$platform" != "linux" ]]; then
        echo "Debian packages are only supported for Linux artifacts" >&2
        exit 1
    fi
    if ! command -v dpkg-deb >/dev/null 2>&1; then
        echo "dpkg-deb is required to build Debian packages" >&2
        exit 1
    fi

    populate_system_package_root "$deb_root"
    mkdir -p "$deb_root/DEBIAN"
    installed_size="$(du -sk "$deb_root/usr" | awk '{ print $1 }')"

    cat > "$deb_root/DEBIAN/control" <<EOF
Package: nvime
Version: ${package_version}
Section: editors
Priority: optional
Architecture: ${deb_arch}
Depends: git
Recommends: neovim
Installed-Size: ${installed_size}
Maintainer: NVIME maintainers <noreply@example.com>
Description: Self-contained Neovim configuration bundle
 NVIME packages the Neovim config and downloaded vim.pack plugins.
 Run nvime-install after installing this package to install into the
 current user's XDG config and data directories.
EOF

    cat > "$deb_root/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
echo "NVIME installed. Run nvime-install as your user to install the config into your XDG directories."
EOF
    chmod 0755 "$deb_root/DEBIAN/postinst"

    dpkg-deb --build --root-owner-group "$deb_root" "$output_path"
    created_paths+=("$output_path")
    echo "Created package: $output_path"
}

build_rpm() {
    local rpm_root="$work_root/rpm-root"
    local rpm_topdir="$work_root/rpmbuild"
    local spec_path="$rpm_topdir/SPECS/nvime.spec"
    local output_path="$artifact_root/${bundle_name}.rpm"
    local built_rpm

    if [[ "$platform" != "linux" ]]; then
        echo "RPM packages are only supported for Linux artifacts" >&2
        exit 1
    fi
    if ! command -v rpmbuild >/dev/null 2>&1; then
        echo "rpmbuild is required to build RPM packages" >&2
        exit 1
    fi

    populate_system_package_root "$rpm_root"
    mkdir -p \
        "$rpm_topdir/BUILD" \
        "$rpm_topdir/BUILDROOT" \
        "$rpm_topdir/RPMS" \
        "$rpm_topdir/SOURCES" \
        "$rpm_topdir/SPECS" \
        "$rpm_topdir/SRPMS"

    cat > "$spec_path" <<EOF
Name: nvime
Version: ${package_version}
Release: 1
Summary: Self-contained Neovim configuration bundle
License: LicenseRef-NVIME
Requires: git
Recommends: neovim

%description
NVIME packages the Neovim config and downloaded vim.pack plugins. Run
nvime-install after installing this package to install into the current user's
XDG config and data directories.

%prep

%build

%install
mkdir -p "%{buildroot}"
cp -a "${rpm_root}/." "%{buildroot}/"

%post
echo "NVIME installed. Run nvime-install as your user to install the config into your XDG directories."

%files
/usr/bin/nvime-install
/usr/share/doc/nvime/README.txt
/usr/share/nvime
EOF

    # Preserve verified upstream bytes: RPM must not strip/rewrite native assets.
    rpmbuild \
        --define '__os_install_post %{nil}' \
        --define 'debug_package %{nil}' \
        --define "_topdir $rpm_topdir" \
        --target "$rpm_arch" \
        -bb "$spec_path"

    built_rpm="$(find "$rpm_topdir/RPMS" -name '*.rpm' -type f -print -quit)"
    if [[ -z "$built_rpm" ]]; then
        echo "rpmbuild did not create an RPM package" >&2
        exit 1
    fi

    cp "$built_rpm" "$output_path"
    created_paths+=("$output_path")
    echo "Created package: $output_path"
}

for package_format in "${package_formats[@]}"; do
    case "$package_format" in
        tar.gz) build_tarball ;;
        dmg) build_dmg ;;
        deb) build_deb ;;
        rpm) build_rpm ;;
        *)
            echo "Unsupported package format: $package_format" >&2
            exit 1
            ;;
    esac
done

run_native_test() (
    unset NVIME_SKIP_BLINK_NATIVE
    NVIME_BLINK_TEST="$repo_root/scripts/ci-blink-test.lua" nvim --headless -i NONE -n \
        --cmd 'lua assert(loadfile(vim.env.NVIME_BLINK_TEST))("guard")' \
        '+lua dofile(vim.env.NVIME_BLINK_TEST)' '+qa!'
)

# Verify actual artifacts in isolated installs, not just the staging directory.
test_archive() (
    local artifact="$1" extracted mounted=0 installed_bundle
    extracted="$(mktemp -d "$work_root/extracted.XXXXXX")"
    trap 'if [[ "$mounted" == 1 ]]; then hdiutil detach "$extracted/mount" >/dev/null; fi; rm -rf "$extracted"' EXIT
    case "$artifact" in
        *.tar.gz)
            tar -xzf "$artifact" -C "$extracted"
            installed_bundle="$extracted/$bundle_name"
            ;;
        *.deb)
            dpkg-deb --extract "$artifact" "$extracted"
            installed_bundle="$extracted/usr/share/nvime"
            ;;
        *.rpm)
            rpm2cpio "$artifact" | (cd "$extracted"; cpio -id --quiet --no-absolute-filenames)
            installed_bundle="$extracted/usr/share/nvime"
            ;;
        *.dmg)
            mkdir "$extracted/mount"
            hdiutil attach -readonly -nobrowse -mountpoint "$extracted/mount" "$artifact" >/dev/null
            mounted=1
            installed_bundle="$extracted/mount"
            ;;
        *) echo "Unsupported artifact: $artifact" >&2; exit 1 ;;
    esac
    python3 "$repo_root/scripts/ci-blink.py" verify \
        --data-root "$installed_bundle/payload/data/nvim" \
        --manifest "$installed_bundle/blink-native.json"
    export HOME="$extracted/home"
    export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state" XDG_CACHE_HOME="$HOME/.cache"
    mkdir -p "$HOME"
    bash "$installed_bundle/install.sh"
    run_native_test

    # A missing native library must fail, not silently download or fall back.
    rm "$XDG_DATA_HOME/nvim/site/pack/core/opt/blink.pairs/lib"/libblink_pairs_parser*
    if run_native_test > "$extracted/missing-native.log" 2>&1; then
        echo "Native test incorrectly accepted a missing library" >&2
        exit 1
    fi
    grep -F 'Missing blink.pairs native library' "$extracted/missing-native.log" >/dev/null
    echo "Verified artifact and missing-library rejection: $artifact"
)

for package_path in "${created_paths[@]}"; do
    test_archive "$package_path"
done

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "artifact_name=${bundle_name}" >> "$GITHUB_OUTPUT"
    {
        echo "package_path<<EOF"
        printf '%s\n' "${created_paths[@]}"
        echo "EOF"
    } >> "$GITHUB_OUTPUT"
fi
