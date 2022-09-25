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
    dashboard.button("u", "Update Plugin", ":PackerSync<CR>"),
    dashboard.button("s", "Start Time", ":StartupTime<CR>"),
    dashboard.button("q", "Quit NVIM", ":qa<CR>")
}
local handle = io.popen('fortune')
if handle == nil then
    return
end
local fortune = handle:read("*a")
handle:close()
dashboard.section.footer.val = fortune
dashboard.config.opts.noautocmd = true

-- autocmd
vim.api.nvim_create_autocmd(
    { "User" },
    {
        pattern = "AlphaReady",
        command = "echo 'ready'"
    }
)

-- enable setup
require('alpha').setup(dashboard.config)
