-- LSP manager
require("lspconfig.diagnostic")
require("lspconfig.rust")

-- DON'T auto format
local skip_file_type = { "c", "cpp" }

local function is_skip_format(filetype)
    for _, pattern in ipairs(skip_file_type) do
        if filetype == pattern then
            return true
        end
    end
    return false
end

local function lsp_setup_format(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    if not client:supports_method('textDocument/formatting') then return end

    if not is_skip_format(vim.bo.filetype) then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
                vim.lsp.buf.format({
                    bufnr = args.buf,
                    id = client.id,
                    timeout_ms = 2000,
                })
            end
        })
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        lsp_setup_format(args)
    end
})

-- Enable inlay hints
vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

vim.lsp.config('*', {
    root_markers = { '.git' },
    on_attach = require('lspconfig.on_attach').on_attach,
})

local lsp_server = {
    "clangd",
    "lua_ls",
    "ruff",
    "pyright",
    "taplo",
    "texlab",
    "neocmake",
}

vim.lsp.enable(lsp_server)

-- Loop through each server and try to load its specific configuration
for _, server in ipairs(lsp_server) do
    pcall(require, "lspconfig.lsp." .. server)
end
