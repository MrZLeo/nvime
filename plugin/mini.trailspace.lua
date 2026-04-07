vim.pack.add({ "https://github.com/echasnovski/mini.trailspace" })

require('mini.trailspace').setup()
vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
        require('mini.trailspace').trim()
    end
})
