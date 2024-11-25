-- TODO: improve code architecture, split on_attach & setup

-- LSP manager
require("lsp.settings")
require("lsp.rust")

-- auto format
local pattern = {
    "*.rs",
    "*.c",
    "*.h",
    "*.cpp",
    -- "*.hpp",
    -- "*.cc",
    "*.lua",
    "*.toml",
    "*.yaml",
    "*.json",
    "*.go",
    "*.build"
}

vim.api.nvim_create_autocmd(
    { "BufWritePre" },
    {
        pattern = pattern,
        command = "lua vim.lsp.buf.format()"
    }
)



vim.cmd('hi link LspInlayHint Comment')
