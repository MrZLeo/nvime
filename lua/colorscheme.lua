-- vim.g.one_allow_italics = false
-- vim.g.edge_dim_foreground = 1
vim.g.edge_menu_selection_background = 'green'
vim.g.edge_better_performance = 1

local colorscheme = "edge"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
    vim.notify("colorscheme " .. colorscheme .. " not found!")
    return
end
