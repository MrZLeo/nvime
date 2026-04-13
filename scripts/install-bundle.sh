#!/usr/bin/env bash

set -euo pipefail

required_nvim_version="0.12.0"

usage() {
    cat <<'EOF'
Usage: ./install.sh [--config-dir PATH] [--data-dir PATH] [--no-backup]

Installs the packaged NVIME config into the standard Neovim config/data
locations by default:
  config: ${XDG_CONFIG_HOME:-$HOME/.config}/nvim
  data:   ${XDG_DATA_HOME:-$HOME/.local/share}/nvim

Options:
  --config-dir PATH  Override the target config directory
  --data-dir PATH    Override the target Neovim data directory
  --no-backup        Replace existing files without creating timestamped backups
  -h, --help         Show this help message
EOF
}

backup_enabled=1
config_target="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
data_target="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config-dir)
            config_target="$2"
            shift 2
            ;;
        --data-dir)
            data_target="$2"
            shift 2
            ;;
        --no-backup)
            backup_enabled=0
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

normalize_version() {
    local version="$1"

    version="${version#v}"
    version="${version%%-*}"
    version="${version%%+*}"
    printf '%s\n' "$version"
}

version_ge() {
    local left right
    local left_parts right_parts
    local index

    left="$(normalize_version "$1")"
    right="$(normalize_version "$2")"

    IFS=. read -r -a left_parts <<<"$left"
    IFS=. read -r -a right_parts <<<"$right"

    for index in 0 1 2; do
        local left_part="${left_parts[$index]:-0}"
        local right_part="${right_parts[$index]:-0}"

        if (( left_part > right_part )); then
            return 0
        fi
        if (( left_part < right_part )); then
            return 1
        fi
    done

    return 0
}

require_nvim() {
    local installed_version

    if ! command -v nvim >/dev/null 2>&1; then
        cat >&2 <<EOF
Neovim is not installed or not available on PATH.
Please install Neovim ${required_nvim_version} or newer before running this installer.
EOF
        exit 1
    fi

    installed_version="$(nvim --version | sed -n '1s/^NVIM v//p' | tr -d '\r')"
    if [[ -z "$installed_version" ]]; then
        echo "Failed to detect the installed Neovim version." >&2
        exit 1
    fi

    if ! version_ge "$installed_version" "$required_nvim_version"; then
        cat >&2 <<EOF
NVIME requires Neovim ${required_nvim_version} or newer.
Detected Neovim ${installed_version}.
Please upgrade Neovim before running this installer.
EOF
        exit 1
    fi

    echo "Detected Neovim ${installed_version}"
}

bundle_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
payload_config="$bundle_root/payload/config/nvim"
payload_pack="$bundle_root/payload/data/nvim/site/pack/core/opt"
pack_target="$data_target/site/pack/core/opt"
timestamp="$(date +%Y%m%d-%H%M%S)"

if [[ ! -d "$payload_config" ]]; then
    echo "Bundled config payload not found: $payload_config" >&2
    exit 1
fi

require_nvim

backup_path() {
    local target="$1"
    local backup_path="${target}.backup.${timestamp}"

    if [[ $backup_enabled -eq 1 && -e "$target" ]]; then
        echo "Backing up $target -> $backup_path"
        mv "$target" "$backup_path"
    fi
}

install_tree() {
    local source="$1"
    local target="$2"

    backup_path "$target"
    rm -rf "$target"
    mkdir -p "$(dirname "$target")"
    cp -R "$source" "$target"
}

echo "Installing NVIME config to $config_target"
install_tree "$payload_config" "$config_target"

if [[ -d "$payload_pack" ]]; then
    echo "Installing bundled plugins to $pack_target"
    install_tree "$payload_pack" "$pack_target"
fi

echo "Installation complete."
echo "Config: $config_target"
echo "Data:   $data_target"
