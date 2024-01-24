-- TODO: improve code architecture, split on_attach & setup

-- LSP manager
-- require("lsp.mason")
-- require("lsp.mason-lspconfig")
require("lsp.settings")

-- auto format
local pattern = {
    "*.rs",
    -- "*.c",
    -- "*.h",
    -- "*.cpp",
    -- "*.hpp",
    -- "*.cc",
    "*.lua",
    "*.toml",
    "*.yaml",
    "*.json",
    "*.go"
}

vim.api.nvim_create_autocmd(
    { "BufWritePre" },
    {
        pattern = pattern,
        command = "lua vim.lsp.buf.format()"
    }
)

-- auto show diagnostic
-- FIXME: if diagnostic show up, we cannot check function document, use `KK`
--        to check document right now
vim.api.nvim_create_autocmd(
    { "CursorHold" },
    {
        command = "lua vim.diagnostic.open_float(nil, {focusable = false})"
    }
)

vim.cmd('hi link LspInlayHint Comment')

-- vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = "LspAttach_inlayhints",
--     callback = function(args)
--         if not (args.data and args.data.client_id) then
--             return
--         end
--
--         local bufnr = args.buf
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         require("lsp-inlayhints").on_attach(client, bufnr)
--     end,
-- })
