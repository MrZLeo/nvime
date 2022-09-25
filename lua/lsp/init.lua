-- TODO: improve code architecture

local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

-- LSP manager
require("lsp.settings").setup()
require("lsp.mason")
require("lsp.mason-lspconfig")

-- auto format
local pattern = {
    "*.rs",
    -- "*.c",
    -- "*.h",
    "*.cpp",
    "*.hpp",
    "*.cc",
    "*.lua",
    "*.toml"
}

vim.api.nvim_create_autocmd(
    { "BufWritePre" },
    {
        pattern = pattern,
        command = "lua vim.lsp.buf.formatting_sync()"
    }
)

-- auto show diagnostic
-- FIXME: if diagnostic show up, we cannot check function document, use `KK` to check document right now
vim.api.nvim_create_autocmd(
    { "CursorHold" },
    {
        command = "lua vim.diagnostic.open_float(nil, {focusable = false})"
    }
)

-- UI
require("fidget").setup {}
