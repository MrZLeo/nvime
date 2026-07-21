#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
current_hooks_path="$(git -C "$repo_root" config --local --get core.hooksPath || true)"

if [[ -n "$current_hooks_path" && "$current_hooks_path" != ".githooks" ]]; then
    echo "Refusing to replace existing core.hooksPath: $current_hooks_path" >&2
    exit 1
fi

git -C "$repo_root" config core.hooksPath .githooks
echo "Git hooks enabled from .githooks"
