-- basic configuration
local default_option = {
    compatible = false,     -- nocompatible with vi
    fileencoding = "utf-8", -- coding format utf-8
    number = true,
    relativenumber = true,
    smartindent = true,
    autoindent = true,
    linebreak = true,
    backup = false,
    swapfile = false,
    writebackup = false,
    hidden = true,
    ignorecase = true, -- ignore case when use '/' to search
    smartcase = true,  -- if enter uppercase, don't ignore case
    history = 500,
    splitbelow = true,
    expandtab = true,
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    smarttab = true,
    shiftround = true,
    autoread = true,
    confirm = true,
    showmode = false,
    timeoutlen = 500,
    updatetime = 100,
    mouse = "a",
    lazyredraw = true,
    cmdheight = 1,
    showmatch = true,
    matchtime = 2,
    clipboard = "unnamedplus",
    signcolumn = "yes", -- prevent shaking when using LSP
    syntax = "on",
    termguicolors = true,
    incsearch = true, -- increase search feedback
    cursorline = true,
    colorcolumn = "100",
    pumheight = 20,
    pumblend = 20,
    guifont = { "Comic Code", ":h15" }, -- only use for GUI, needs to install font

    -- use smart fold
    foldmethod = "expr",
    foldlevel = 20,
    foldexpr = "nvim_treesitter#foldexpr()",

    -- external configuration
    -- exrc = true

    -- spell
    spelllang = { "en_us", "cjk" },
    spellfile = vim.fn.expand("~/.config/nvim/spell/en.utf-8.add")
}

-- Disable true color if not supported
-- FIXME: some plugins seem to require truecolor to work
if vim.env.TERM_PROGRAM == 'Apple_Terminal' then
    default_option.termguicolors = false
end

-- enable all setting
for k, v in pairs(default_option) do
    vim.opt[k] = v
end

local function paste()
    return {
        vim.fn.split(vim.fn.getreg(""), "\n"),
        vim.fn.getregtype(""),
    }
end

vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
        ["+"] = paste,
        ["*"] = paste,
    },
}

-- latex support
vim.g.tex_flavor = 'latex'
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.tex" },
    command = [[set spell]]
})

-- neovim cannot detect gn format right now
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.gn", "*.gni" },
    command = "set filetype=gn",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.ets" },
    command = "set filetype=typescript",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.h" },
    command = "set filetype=c",
})

-- CSV
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.csv" },
    callback = function()
        vim.cmd [[set colorcolumn=]]
        vim.cmd [[CsvViewEnable]]
    end
})
