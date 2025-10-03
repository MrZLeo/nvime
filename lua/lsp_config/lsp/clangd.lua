vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        -- "--query-driver=/usr/bin/g++",
        "--completion-style=detailed",
        -- "--malloc-trim",
        "--header-insertion=never",
        "--pch-storage=memory",
        "--offset-encoding=utf-16"
    },
    init_options = {
        fallbackFlags = { '--std=gnu++23' }
    },
})
