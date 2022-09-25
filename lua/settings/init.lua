local plugins = {
    "alpha",
    "chadtree",
    "cmp",
    "commment",
    "dressing",
    "impatient",
    "lualine",
    "nvim-autopairs",
    "nvim-colorizer",
    "nvim-surround",
    "nvim-treesitter",
    "nvim-treesitter-refactor",
    "nvim-treesitter-textobjects",
    "nvim-ts-rainbow",
    "symbols-outline",
    "telescope",
    "todo",
    "vgit",
    "whitespace"
}

for _, plugin in pairs(plugins) do
    require("settings." .. plugin)
end
