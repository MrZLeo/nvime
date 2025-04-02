---@type vim.lsp.Config
return {
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
    root_markers = { '.clangd', 'compile_commands.json' },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },

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
