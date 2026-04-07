vim.pack.add({ "https://github.com/hedyhli/outline.nvim" })

require("outline").setup({
    keymaps = {
        close = { "<Esc>", "q" },
        code_actions = "a",
        fold = "h",
        fold_all = "W",
        fold_reset = "R",
        goto_location = "<Cr>",
        hover_symbol = "K",
        peek_location = "<Tab>",
        rename_symbol = "r",
        toggle_preview = "p",
        unfold = "l",
        unfold_all = "E"
    }
})
