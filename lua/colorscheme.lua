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

-- Link RainbowDelimiter colors to theme's color palette
vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { link = "Blue" })
vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { link = "Red" })
vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { link = "Green" })
vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { link = "Purple" })
vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { link = "Yellow" })
vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { link = "Cyan" })
