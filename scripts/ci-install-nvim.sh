#!/usr/bin/env bash

set -euo pipefail

print_bin_dir=0
nvim_version="${NVIME_NEOVIM_VERSION:-latest}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --print-bin-dir)
            print_bin_dir=1
            shift
            ;;
        --version)
            nvim_version="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

runner_temp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
install_root="${NVIME_NEOVIM_ROOT:-$runner_temp}"
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

if [[ "$nvim_version" == "latest" ]]; then
    download_url="https://github.com/neovim/neovim/releases/latest/download/$archive"
else
    download_url="https://github.com/neovim/neovim/releases/download/v${nvim_version#v}/$archive"
fi

install_dir="${archive%.tar.gz}"
install_path="$install_root/$install_dir"
bin_dir="$install_path/bin"

if [[ ! -x "$bin_dir/nvim" ]]; then
    download_root="$(mktemp -d "${runner_temp%/}/nvime-nvim.XXXXXX")"
    cleanup_download() {
        rm -rf "$download_root"
    }
    trap cleanup_download EXIT

    mkdir -p "$install_root"
    echo "Installing Neovim ${nvim_version} into $install_path" >&2
    curl -fsSL -o "$download_root/$archive" "$download_url"
    tar -xzf "$download_root/$archive" -C "$download_root"
    rm -rf "$install_path"
    mv "$download_root/$install_dir" "$install_path"
else
    echo "Using cached Neovim at $install_path" >&2
fi

if [[ -n "${GITHUB_PATH:-}" ]]; then
    echo "$bin_dir" >> "$GITHUB_PATH"
elif [[ $print_bin_dir -eq 0 ]]; then
    echo "Add this Neovim binary directory to PATH: $bin_dir"
fi

if [[ $print_bin_dir -eq 1 ]]; then
    printf '%s\n' "$bin_dir"
fi
