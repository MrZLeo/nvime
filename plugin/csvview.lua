vim.api.nvim_create_autocmd("FileType", {
    once = true,
    pattern = { "csv", "tsv" },
    callback = function()
        vim.pack.add({
            "https://github.com/hat0uma/csvview.nvim",
        })

        require("csvview").setup({
            parser = { comments = { "#", "//" } },
        })
    end,
})
