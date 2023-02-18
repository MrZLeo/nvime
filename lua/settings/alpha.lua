-- define my dashboard
local dashboard = require 'alpha.themes.dashboard'
dashboard.section.header.val = {
    [[ ███▄    █ ██▒   █▓ ██▓ ███▄ ▄███▓▓█████]],
    [[ ██ ▀█   █▓██░   █▒▓██▒▓██▒▀█▀ ██▒▓█   ▀]],
    [[▓██  ▀█ ██▒▓██  █▒░▒██▒▓██    ▓██░▒███]],
    [[▓██▒  ▐▌██▒ ▒██ █░░░██░▒██    ▒██ ▒▓█  ▄]],
    [[▒██░   ▓██░  ▒▀█░  ░██░▒██▒   ░██▒░▒████▒]],
    [[░ ▒░   ▒ ▒   ░ ▐░  ░▓  ░ ▒░   ░  ░░░ ▒░ ░]],
    [[░ ░░   ░ ▒░  ░ ░░   ▒ ░░  ░      ░ ░ ░  ░]],
    [[   ░   ░ ░     ░░   ▒ ░░             ░]],
    [[         ░']],
}
dashboard.section.buttons.val = {
    dashboard.button("e", "New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("u", "Update Plugin", ":Lazy sync<CR>"),
    dashboard.button("s", "Start Time", ":StartupTime<CR>"),
    dashboard.button("q", "Quit NVIM", ":qa<CR>")
}
dashboard.config.opts.noautocmd = true

-- enable setup
require('alpha').setup(dashboard.config)

-- autocmd
vim.api.nvim_create_autocmd(
    { "User" },
    {
        pattern = "AlphaReady",
        command = "echo 'ready'"
    }
)
