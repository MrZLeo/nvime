vim.lsp.config("lua_ls",  {
    settings = {
        Lua = {
            hint = { enable = true },
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique
            -- identifier
            telemetry = {
                enable = false,
            },
        },
    }
})
