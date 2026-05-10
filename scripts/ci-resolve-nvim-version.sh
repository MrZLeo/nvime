#!/usr/bin/env bash

set -euo pipefail

nvim_version="${NVIME_NEOVIM_VERSION:-latest}"

if [[ "$nvim_version" != "latest" ]]; then
    printf '%s\n' "${nvim_version#v}"
    exit 0
fi

latest_release="$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest)"
latest_tag="$(
    printf '%s\n' "$latest_release" |
        sed -n 's/^[[:space:]]*"tag_name":[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' |
        head -n 1
)"

if [[ -z "$latest_tag" ]]; then
    echo "Failed to resolve the latest Neovim release version." >&2
    exit 1
fi

printf '%s\n' "$latest_tag"
