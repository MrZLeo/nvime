#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
system="$(nix eval --impure --raw --expr builtins.currentSystem)"
locked_version="$(nix eval --raw --no-write-lock-file "$repo_root#devShells.$system.ci.NVIME_NEOVIM_VERSION")"
requested="${NVIME_NEOVIM_VERSION:-latest}"
if [[ "$requested" != latest && "${requested#v}" != "$locked_version" ]]; then
    echo "Requested Neovim $requested does not match flake.lock ($locked_version)." >&2
    exit 1
fi
if [[ ! "$locked_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid locked Neovim version: $locked_version" >&2
    exit 1
fi
printf '%s\n' "$locked_version"
