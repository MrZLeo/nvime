local config = {
    -- 解析器的安装
    ensure_installed = {
        "bash", "bibtex", "c", "cmake", "comment", "cpp", "diff", "dockerfile",
        "fish", "git_rebase", "gitattributes", "go", "gomod", "gowork", "haskell",
        "json", "json5", "latex", "llvm", "lua", "make", "markdown",
        "markdown_inline", "ninja", "perl", "proto", "python", "rst", "rust",
        "sql", "toml", "vim", "yaml", "kdl", "gn", "typescript"
    },
    highlight = {
        enable = true, -- false将禁用整个插件
        additional_vim_regex_highlighting = false,
        -- disable = { "javascript" }, -- 不使用该插件的语言
    },
    -- indent
    indent = {
        enable = true
    },
    -- rainbow
    rainbow = {
        enable = true,
        -- disable = { "javascript" }
    },
}

-- enable settings
require("nvim-treesitter.configs").setup(config)
