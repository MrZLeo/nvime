#!/usr/bin/env bash

set -euo pipefail

runner_temp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
    Linux)
        case "$arch" in
            x86_64) archive="nvim-linux-x86_64.tar.gz" ;;
            aarch64|arm64) archive="nvim-linux-arm64.tar.gz" ;;
            *) echo "Unsupported Linux architecture: $arch" >&2; exit 1 ;;
        esac
        ;;
    Darwin)
        case "$arch" in
            x86_64) archive="nvim-macos-x86_64.tar.gz" ;;
            arm64) archive="nvim-macos-arm64.tar.gz" ;;
            *) echo "Unsupported macOS architecture: $arch" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "Unsupported operating system: $os" >&2
        exit 1
        ;;
esac

curl -fsSL -o "$runner_temp/$archive" \
    "https://github.com/neovim/neovim/releases/latest/download/$archive"
tar -xzf "$runner_temp/$archive" -C "$runner_temp"

install_dir="${archive%.tar.gz}"
bin_dir="$runner_temp/$install_dir/bin"

if [[ -n "${GITHUB_PATH:-}" ]]; then
    echo "$bin_dir" >> "$GITHUB_PATH"
else
    echo "Add this Neovim binary directory to PATH: $bin_dir"
fi

