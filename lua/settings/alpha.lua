-- autocmd
vim.api.nvim_create_autocmd(
    { "User" },
    {
        pattern = "AlphaReady",
        command = "echo 'ready'"
    }
)
