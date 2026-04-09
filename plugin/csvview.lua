local csvview_loaded = false

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "csv", "tsv" },
    callback = function()
        if not csvview_loaded then
            vim.pack.add({
                "https://github.com/hat0uma/csvview.nvim",
            })

            require("csvview").setup({
                parser = { comments = { "#", "//" } },
            })
            csvview_loaded = true
        end

        vim.opt_local.colorcolumn = ""
        vim.cmd("CsvViewEnable")
    end,
})
