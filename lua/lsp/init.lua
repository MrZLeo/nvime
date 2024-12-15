-- TODO: improve code architecture, split on_attach & setup

-- LSP manager
require("lsp.settings")
require("lsp.rust")

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

vim.keymap.set('v', 'ff',
    function()
        vim.lsp.buf.format({ range = { start = vim.fn.getpos("'<"), ['end'] = vim.fn.getpos("'>") } })
        vim.api.nvim_input('<Esc>') -- Exit visual mode
    end, {})


vim.cmd('hi link LspInlayHint Comment')
