-- list of plugin settings
local plugins = {
    "alpha",
    "chadtree",
    -- "cmp",
    "lualine",
    "nvim-treesitter",
    "nvim-treesitter-refactor",
    "nvim-treesitter-textobjects",
    "nvim-ts-rainbow",
    "symbols-outline",
    "telescope",
    "whitespace",
    "ssr"
}

for _, plugin in pairs(plugins) do
    require("settings." .. plugin)
end
