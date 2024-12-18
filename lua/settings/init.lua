-- list of plugin settings
local plugins = {
    "lualine",
    "nvim-treesitter",
    "nvim-ts-rainbow",
    "whitespace",
}

for _, plugin in pairs(plugins) do
    require("settings." .. plugin)
end
