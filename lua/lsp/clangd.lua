local M = {}

local opt = {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--query-driver=/usr/bin/gcc",
        "--completion-style=detailed",
        -- "--malloc-trim",
        "--header-insertion=never",
        "--pch-storage=memory",
        "--offset-encoding=utf-16"
    },
    settings = {
        clangd = {
            InlayHints = {
                Designators = true,
                Enabled = true,
                ParameterNames = true,
                DeducedTypes = true,
            },
            fallbackFlags = { "-std=c++20" },
        },
    }
}

local ext = {
    autoSetHints = false,
}

M.opt = opt
M.ext = ext

return M
