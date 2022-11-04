local config = {
    -- 解析器的安装，all全部安装
    ensure_installed = {
        "c", "cpp", "rust", "lua",
        "bash", "cmake", "css",
        "json", "java", "json5", "llvm",
        "make", "ninja", "perl", "python",
        "scala", "toml", "verilog", "vim",
        "haskell"
    },

    -- 高亮配置
    highlight = {
        enable = true, -- false将禁用整个插件
        disable = {}, -- 不使用该插件的语言
    },

    -- 块选择，还不太会使用，暂时保留
    incremental_selection = {
        enable = true,
        disable = {},
        keymaps = { -- mappings for incremental selection (visual mappings)
            init_selection = 'gnn', -- maps in normal mode to init the node/scope selection
            node_incremental = "grn", -- increment to the upper named parent
            scope_incremental = "grc", -- increment to the upper scope (as defined in locals.scm)
            node_decremental = "grm", -- decrement to the previous node
        },
    },

    -- indent
    indent = {
        enable = true
    },

    -- rainbow
    rainbow = {
        enable = true,
        disable = { 'bash' }
    }
}

-- enable settings
require("nvim-treesitter.configs").setup(config)
