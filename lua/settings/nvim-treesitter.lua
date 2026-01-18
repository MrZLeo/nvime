local ensure_installed = {
    "bash", "bibtex", "c", "cmake", "comment", "cpp", "diff", "dockerfile",
    "fish", "git_rebase", "gitattributes", "go", "gomod", "gowork", "haskell",
    "json", "json5", "latex", "llvm", "lua", "make", "markdown",
    "markdown_inline", "ninja", "perl", "proto", "python", "rst", "rust",
    "sql", "toml", "vim", "yaml", "kdl", "gn", "typescript"
}

-- enable settings
local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
    return
end

treesitter.install(ensure_installed):wait(3000)
treesitter.update(ensure_installed)

vim.api.nvim_create_autocmd('FileType', {
    pattern = { '<filetype>' },
    callback = function() vim.treesitter.start() end,
})
