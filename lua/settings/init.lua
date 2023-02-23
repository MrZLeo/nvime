-- list of plugin settings
local plugins = {
    "alpha",
    "chadtree",
    "cmp",
    "dressing",
    "lualine",
    "nvim-colorizer",
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
