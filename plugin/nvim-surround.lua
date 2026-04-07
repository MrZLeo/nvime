vim.pack.add({
    {
        src = "https://github.com/kylechui/nvim-surround",
        version = vim.version.range('4.x')
    }
})

require("nvim-surround").setup()
