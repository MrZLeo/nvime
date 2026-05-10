#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log_file="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/nvime-ci-lua-syntax.log"

NVIM_LOG_FILE="$log_file" NVIME_REPO_ROOT="$repo_root" nvim --headless -u NONE -i NONE '+lua
local root = vim.env.NVIME_REPO_ROOT
local patterns = {
    "init.lua",
    "lua/**/*.lua",
    "plugin/**/*.lua",
}

local failed = false
for _, pattern in ipairs(patterns) do
    local files = vim.fn.globpath(root, pattern, false, true)
    table.sort(files)

    for _, file in ipairs(files) do
        local _, err = loadfile(file)
        if err then
            failed = true
            vim.api.nvim_err_writeln(file .. ": " .. err)
        end
    end
end

if failed then
    vim.cmd("cquit")
end
' '+qa'
