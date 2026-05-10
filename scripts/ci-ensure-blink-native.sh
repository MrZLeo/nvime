#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log_file="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/nvime-ci-blink-native.log"

NVIM_LOG_FILE="$log_file" nvim --headless -u NONE -i NONE \
    -S "$repo_root/scripts/ci-ensure-blink-native.lua" \
    '+qa'
