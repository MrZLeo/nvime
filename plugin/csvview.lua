vim.pack.add({ "https://github.com/hat0uma/csvview.nvim" })

require("csvview").setup({
    parser = { comments = { "#", "//" } },
})
