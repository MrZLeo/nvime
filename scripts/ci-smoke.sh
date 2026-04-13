#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base_temp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
work_root="$(mktemp -d "${base_temp%/}/nvime-ci.XXXXXX")"

cleanup() {
    rm -rf "$work_root"
}
trap cleanup EXIT

export HOME="$work_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$work_root/data"
export XDG_STATE_HOME="$work_root/state"
export XDG_CACHE_HOME="$work_root/cache"

config_root="$XDG_CONFIG_HOME/nvim"

mkdir -p \
    "$config_root" \
    "$XDG_DATA_HOME" \
    "$XDG_STATE_HOME" \
    "$XDG_CACHE_HOME"

cp -R "$repo_root/." "$config_root"

echo "Using temporary config root: $config_root"
echo "Using temporary data root: $XDG_DATA_HOME"
echo "Bootstrapping plugins from nvim-pack-lock.json"
nvim --headless '+qa'

echo "Verifying clean headless startup"
nvim --headless '+qa'
