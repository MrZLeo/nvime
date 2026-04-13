if vim.fn.has("nvim-0.12") == 0 or vim.pack == nil then
    vim.o.loadplugins = false
    vim.api.nvim_err_writeln("NVIME requires Neovim 0.12 or newer (with vim.pack support).")
    return
end

vim.loader.enable(true)

-- load basic settings
require("base")

-- load keymap
require("keymap")

-- load utils
require("utils")
