vim.g.rustaceanvim = {
    -- LSP configuration
    server = {
        on_attach = require('lsp.on_attach').on_attach,
        default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
                -- checkOnSave = {
                --     command = "clippy",
                --     allTargets = false
                -- },
            },
        },
    },
}

