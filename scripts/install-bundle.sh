#!/usr/bin/env bash

set -euo pipefail

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

bundle_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
payload_config="$bundle_root/payload/config/nvim"
payload_pack="$bundle_root/payload/data/nvim/site/pack/core/opt"
pack_target="$data_target/site/pack/core/opt"
timestamp="$(date +%Y%m%d-%H%M%S)"

if [[ ! -d "$payload_config" ]]; then
    echo "Bundled config payload not found: $payload_config" >&2
    exit 1
fi

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

