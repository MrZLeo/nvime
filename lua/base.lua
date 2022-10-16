-- basic configuration

local default_option = {
    compatible = false, -- nocompatible with vi
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
    smartcase = true, -- if enter uppercase, don't ignore case
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
    colorcolumn = "80",
    pumheight = 20,
    pumblend = 20,
    guifont = { "Comic Code", ":h15" }, -- only use for GUI, needs to install font
}

-- enable all setting
for k, v in pairs(default_option) do
    vim.opt[k] = v
end
