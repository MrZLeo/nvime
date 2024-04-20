-- list of plugin settings
local plugins = {
    "alpha",
    "chadtree",
    "lualine",
    "nvim-treesitter",
    "nvim-ts-rainbow",
    "symbols-outline",
    "whitespace",
}

for _, plugin in pairs(plugins) do
    require("settings." .. plugin)
end
