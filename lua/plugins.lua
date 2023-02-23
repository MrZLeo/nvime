-- Automatically install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we don't error out on first use
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
    return
end

-- Install your plugins here
lazy.setup({
    -- surrounding
    {
        'kylechui/nvim-surround',
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = true,
        lazy = true
    },

    -- rainbow brackets
    {
        'mrjones2014/nvim-ts-rainbow',
        config = function()
            local config = {
                rainbow = {
                    enable = true,
                    -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
                    extended_mode = true,
                }
            }
            require 'nvim-treesitter.configs'.setup(config)
        end
    },
    -- color theme
    {
        'sainnhe/edge',
        lazy = false
    },

    -- treesitter
    'nvim-treesitter/nvim-treesitter-refactor',
    'romgrk/nvim-treesitter-context',
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    { 'yianwillis/vimcdoc',              event = "VeryLazy" },

    -- count the hightlight
    {
        'kevinhwang91/nvim-hlslens',
        config = true,
        lazy = true
    },

    -- comment
    {
        'numToStr/Comment.nvim',
        config = true,
        lazy = true
    },

    -- start time
    { 'dstein64/vim-startuptime',            cmd = 'StartupTime' },

    -- indent line
    { 'lukas-reineke/indent-blankline.nvim', event = "BufReadPre" },

    -- git
    {
        'tanvirtin/vgit.nvim',
        config = true,
        event = "VeryLazy"
    },

    -- color
    'norcalli/nvim-colorizer.lua',

    -- file explorer
    {
        'ms-jpq/chadtree',
        branch = 'chad',
        build = 'python3 -m chadtree deps',
        cmd = 'CHADopen'
    },

    -- status line
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true }
    },

    -- remove space in the end of line
    { 'ntpeters/vim-better-whitespace', lazy = true },

    -- pair brackets
    {
        'windwp/nvim-autopairs',
        config = function()
            local config = {
                map_cr = true,
                map_complete = false
            }
            require("nvim-autopairs").setup(config)
        end,
        lazy = true
    },

    -- startup page
    'goolord/alpha-nvim',

    -- LSP support
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp', -- LSP provider
            'hrsh7th/cmp-buffer', -- buffer completions
            'hrsh7th/cmp-path', -- path completions
            'neovim/nvim-lspconfig', -- enable LSP
            'L3MON4D3/LuaSnip', -- Snippet engine
            'saadparwaiz1/cmp_luasnip', -- Snippet cmp interface
            'j-hui/fidget.nvim', -- UI for LSP loading
        },
        -- load cmp on InsertEnter
        event = "InsertEnter",
    }, -- The completion plugin
    {
        'williamboman/mason.nvim', -- LSP installer
        event = "VeryLazy"
    },
    {
        'williamboman/mason-lspconfig.nvim', -- lspconfig Adapter
        dependencies = {
            'simrat39/rust-tools.nvim', -- Rust LSP
            'hrsh7th/cmp-nvim-lua', -- Lua LSP
            'p00f/clangd_extensions.nvim', -- C/C++ LSP
        },
        event = "VeryLazy"
    },

    --telescope
    {
        'nvim-telescope/telescope.nvim', version = '0.1.0',
        dependencies = { 'nvim-lua/plenary.nvim' },
        lazy = true
    },

    { "stevearc/dressing.nvim",         event = "VeryLazy" },

    -- outline
    { 'simrat39/symbols-outline.nvim',  lazy = true },

    -- structural replacement
    {
        "cshuaimin/ssr.nvim",
        -- Calling setup is optional.
        config = function()
            require("ssr").setup {
                min_width = 50,
                min_height = 5,
                max_width = 120,
                max_height = 25,
                keymaps = {
                    close = "q",
                    next_match = "n",
                    prev_match = "N",
                    replace_confirm = "<cr>",
                    replace_all = "<leader><cr>",
                },
            }
        end,
        lazy = true
    },
})
