-- list of plugin settings
local plugins = {
    "lualine",
    "nvim-treesitter",
    "whitespace",
}

for _, plugin in pairs(plugins) do
    require("settings." .. plugin)
end
