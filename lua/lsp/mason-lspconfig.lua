require("mason-lspconfig").setup({
    automatic_installation = true,
    -- FIXME: clangd no support linux-aarch64
    ensure_installed = { "rust_analyzer", "lua_ls", "clangd", "taplo" }
})

-- on_attach function
local on_attach = require("lsp.on_attach").on_attach

require("mason-lspconfig").setup_handlers({
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {
            on_attach = on_attach
        }
    end,
    -- Next, you can provide targeted overrides for specific servers.

    -- 1. rust_analyzer
    ["rust_analyzer"] = function()
        local opt = require("lsp.rust")
        opt.server.on_attach = on_attach
        require("rust-tools").setup(opt)
    end,
    -- 2. lua_ls
    ["lua_ls"] = function()
        local opt = require("lsp.lua")
        opt.on_attach = on_attach
        require("lspconfig").lua_ls.setup(opt)
    end,
    -- 3. clangd
    ["clangd"] = function()
        local opt = require("lsp.clangd")
        opt.server.on_attach = on_attach
        require("clangd_extensions").setup(opt)
    end,
})
