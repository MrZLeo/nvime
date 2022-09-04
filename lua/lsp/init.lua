local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

require("lsp.settings").setup()
require("lsp.rust")
require("lsp.lua")
require("lsp.clangd")

-- auto format
vim.cmd [[ autocmd FileType rust,c,cpp,lua autocmd BufWritePre * :lua vim.lsp.buf.formatting_sync(nil, 200) ]]
