#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sandbox="$(mktemp -d "${TMPDIR:-/tmp}/nvime-pack-update.XXXXXX")"
trap 'rm -rf "$sandbox"' EXIT

# Never read the user's Git configuration or touch installed plugins/config.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_CONFIG GIT_CONFIG_COUNT
unset GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
export HOME="$sandbox/home"
export XDG_CONFIG_HOME="$sandbox/config with spaces"
export XDG_DATA_HOME="$sandbox/data"
export XDG_STATE_HOME="$sandbox/state"
export XDG_CACHE_HOME="$sandbox/cache"
export NVIM_APPNAME=nvim
export NVIM_LOG_FILE="$sandbox/nvim.log"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_TERMINAL_PROMPT=0
export NVIME_TEST_ROOT="$sandbox"
export NVIME_REPO_ROOT="$repo_root"
mkdir -p "$HOME" "$XDG_CONFIG_HOME/nvim"

nvim --headless -u NONE -i NONE -n -l "$repo_root/scripts/test-pack-update.lua"
