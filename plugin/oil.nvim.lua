-- file explorer

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
    columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
    },
    view_options = {
        show_hidden = true
    },
})
