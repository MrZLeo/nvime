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
NVIME_SKIP_BLINK_NATIVE=1 run_headless_nvim

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

cp "$repo_root/scripts/install-bundle.sh" "$bundle_root/install.sh"
chmod +x "$bundle_root/install.sh"

cat > "$bundle_root/README.txt" <<EOF
NVIME ${version}

Contents:
- install.sh: installs the bundled config and downloaded plugins
- payload/: the packaged Neovim config and vim.pack plugin directory

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

    rpmbuild \
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

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "artifact_name=${bundle_name}" >> "$GITHUB_OUTPUT"
    {
        echo "package_path<<EOF"
        printf '%s\n' "${created_paths[@]}"
        echo "EOF"
    } >> "$GITHUB_OUTPUT"
fi
