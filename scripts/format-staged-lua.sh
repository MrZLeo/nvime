#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v stylua >/dev/null 2>&1; then
    echo "pre-commit: stylua is not installed or not on PATH" >&2
    exit 1
fi

lua_files=()
while IFS= read -r -d '' file; do
    lua_files+=("$file")
done < <(git diff --cached --name-only --diff-filter=ACMR -z -- '*.lua')

if [[ ${#lua_files[@]} -eq 0 ]]; then
    exit 0
fi

if ! git diff --quiet -- "${lua_files[@]}"; then
    echo "pre-commit: staged Lua files also contain unstaged changes; skipping format" >&2
    echo "Commit or stash those changes, then try again." >&2
    exit 1
fi

stylua --respect-ignores -- "${lua_files[@]}"

if ! git diff --quiet -- "${lua_files[@]}"; then
    echo "pre-commit: StyLua reformatted staged Lua files." >&2
    echo "Review and stage the formatting changes, then commit again." >&2
    exit 1
fi
