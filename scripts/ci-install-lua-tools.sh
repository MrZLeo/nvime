#!/usr/bin/env bash

set -euo pipefail

tool_root="${NVIME_LUA_TOOL_ROOT:-${RUNNER_TEMP:-/tmp}/nvime-lua-tools}"

mkdir -p "$tool_root"

install_crate() {
    local binary="$1"
    local crate="$2"
    local version="$3"
    shift 3

    if [[ -x "$tool_root/bin/$binary" ]]; then
        echo "$binary already installed at $tool_root/bin/$binary"
        return
    fi

    cargo install "$crate" \
        --version "$version" \
        --locked \
        --root "$tool_root" \
        "$@"
}

install_crate stylua stylua 2.4.1 --features luajit
install_crate selene selene 0.30.0 --no-default-features

if [[ -n "${GITHUB_PATH:-}" ]]; then
    echo "$tool_root/bin" >> "$GITHUB_PATH"
else
    export PATH="$tool_root/bin:$PATH"
    echo "Add this Lua tooling directory to PATH: $tool_root/bin"
fi
