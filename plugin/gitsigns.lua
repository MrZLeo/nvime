if vim.fn.executable("git") == 0 then
    return
end

vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

require("gitsigns").setup()
