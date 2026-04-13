#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base_temp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
work_root="$(mktemp -d "${base_temp%/}/nvime-package.XXXXXX")"

cleanup() {
    rm -rf "$work_root"
}
trap cleanup EXIT

version="${GITHUB_REF_NAME:-}"
if [[ -z "$version" ]]; then
    version="$(git -C "$repo_root" describe --tags --always)"
fi

os="${NVIME_PACKAGE_OS:-$(uname -s)}"
arch="${NVIME_PACKAGE_ARCH:-$(uname -m)}"

case "$os" in
    Linux)
        platform="linux"
        package_ext="tar.gz"
        ;;
    Darwin)
        platform="macos"
        package_ext="dmg"
        ;;
    *)
        echo "Unsupported operating system: $os" >&2
        exit 1
        ;;
esac

case "$arch" in
    x86_64) arch_label="x86_64" ;;
    aarch64|arm64) arch_label="arm64" ;;
    *)
        echo "Unsupported architecture: $arch" >&2
        exit 1
        ;;
esac

bundle_name="nvime-${version}-${platform}-${arch_label}"
artifact_root="${ARTIFACT_OUTPUT_DIR:-${base_temp%/}/nvime-artifacts}"
output_path="$artifact_root/${bundle_name}.${package_ext}"

export HOME="$work_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$work_root/data"
export XDG_STATE_HOME="$work_root/state"
export XDG_CACHE_HOME="$work_root/cache"

config_root="$XDG_CONFIG_HOME/nvim"
data_root="$XDG_DATA_HOME/nvim"
bundle_root="$work_root/$bundle_name"
payload_root="$bundle_root/payload"
payload_config_root="$payload_root/config/nvim"
payload_data_root="$payload_root/data/nvim"

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
nvim --headless '+qa'
nvim --headless '+qa'

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
    rsync -a "$data_root/" "$payload_data_root/"
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

if [[ "$platform" == "linux" ]]; then
    tar -C "$work_root" -czf "$output_path" "$bundle_name"
else
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
fi

echo "Created package: $output_path"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "artifact_name=${bundle_name}" >> "$GITHUB_OUTPUT"
    echo "package_path=${output_path}" >> "$GITHUB_OUTPUT"
fi
