require("mason-lspconfig").setup({
    automatic_installation = true,
    -- FIXME: clangd no support linux-aarch64
    ensure_installed = { "rust_analyzer", "lua_ls", "clangd", "taplo" }
})

-- on_attach function
local on_attach = require("lsp.on_attach").on_attach
-- local rust_on_attach = require("lsp.on_attach").rust_on_attach

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
        require("clangd_extensions").setup(opt)
        require("lspconfig")["clangd"].setup {
            on_attach = on_attach,
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--query-driver=/usr/bin/gcc,/usr/bin/clang,/usr/bin/g++,/usr/bin/clang++",
                "--completion-style=detailed",
                "--header-insertion=iwyu",
                "--pch-storage=memory",
                "-j",
                "24"
            },
        }
    end,
})
