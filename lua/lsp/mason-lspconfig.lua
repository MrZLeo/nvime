require("mason-lspconfig").setup({
    automatic_installation = true,
    ensure_installed = { "rust_analyzer", "sumneko_lua", "clangd", "taplo" }
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

    -- 2. sumneko_lua
    ["sumneko_lua"] = function()
        local opt = require("lsp.lua")
        opt.on_attach = on_attach
        require("lspconfig").sumneko_lua.setup(opt)
    end,

    -- 3. clangd
    ["clangd"] = function()
        local opt = require("lsp.clangd")
        opt.server.on_attach = on_attach
        require("clangd_extensions").setup(opt)
    end,

})
