local arch_support_clangd = { "amd64", "x86_64" }
local is_support_clangd = function(arch)
    for _, valid_arch in ipairs(arch_support_clangd) do
        if arch == valid_arch then
            return true
        end
    end
    return false
end

local preinstall_lsp = { "rust_analyzer", "lua_ls", "clangd", "taplo" }

require("mason-lspconfig").setup({
    automatic_installation = true,
    ensure_installed = vim.tbl_filter(function(server)
        if server == "clangd" then
            return is_support_clangd(vim.uv.os_uname().machine)
        end
        return true
    end, preinstall_lsp)
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
    ['rust_analyzer'] = function() end,
    -- ["rust_analyzer"] = function()
    --     local opt = require("lsp.rust")
    --     opt.server.on_attach = on_attach
    --     require("rust-tools").setup(opt)
    -- end,
    -- 2. lua_ls
    ["lua_ls"] = function()
        local opt = require("lsp.lua")
        opt.on_attach = on_attach
        require("lspconfig").lua_ls.setup(opt)
    end,
    -- 3. clangd
    ["clangd"] = function()
        local opt = require("lsp.clangd")
        require("lspconfig")["clangd"].setup {
            on_attach = on_attach,
            cmd = {
                "clangd",
                -- "/home/mrzleo/oh-weekly/prebuilts/clang/ohos/linux-x86_64/llvm/bin/clangd",
                "--background-index",
                "--clang-tidy",
                "--query-driver=/usr/bin/gcc",
                -- "--query-driver=/home/mrzleo/oh/prebuilts/clang/ohos/linux-x86_64/llvm/bin/clang",
                "--completion-style=detailed",
                -- "--malloc-trim",
                "--header-insertion=iwyu",
                "--pch-storage=memory",
                "--offset-encoding=utf-16"
            },
        }
        require("clangd_extensions").setup(opt)
    end,
    -- 4. pylyzer
    ["pylyzer"] = function()
        require("lspconfig")["pylyzer"].setup {
            on_attach = on_attach,
            -- python = {
            --     checkOnType = false,
            --     diagnostics = true,
            --     inlayHints = true,
            --     smartCompletion = true
            -- },
            single_file_support = true
        }
    end
})
