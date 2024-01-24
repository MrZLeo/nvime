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

-- Lazy option
local option = {
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true, -- reset the package path to improve startup time
        rtp = {
            reset = true,      -- reset the runtime path to $VIMRUNTIME and your config directory
            ---@type string[]
            paths = {},        -- add any custom paths here that you want to includes in the rtp
            ---@type string[] list any plugins you want to disable here
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
}

-- list of plugins
local plugins = {
    -- surrounding
    {
        'kylechui/nvim-surround',
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = true,
        event = "BufReadPre"
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
    { 'nvim-treesitter/nvim-treesitter',     build = ':TSUpdate' },
    'nvim-treesitter/nvim-treesitter-refactor',
    'romgrk/nvim-treesitter-context',
    -- count the hightlight
    {
        'kevinhwang91/nvim-hlslens',
        config = true,
        event = "InsertEnter",
    },
    -- comment
    {
        'numToStr/Comment.nvim',
        config = true,
        event = "BufReadPre"
    },
    -- indent line
    { 'lukas-reineke/indent-blankline.nvim', event = "BufReadPre" },
    -- git message
    {
        'tanvirtin/vgit.nvim',
        config = true,
        -- cmd = "VGit toggle_live_blame"
    },
    -- color
    {
        'norcalli/nvim-colorizer.lua',
        config = true
    },
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
        dependencies = {
            'kyazdani42/nvim-web-devicons',
            config = true,
        }
    },
    -- remove space in the end of line
    {
        'ntpeters/vim-better-whitespace',
        event = "BufWritePre"
    },
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
    {
        'goolord/alpha-nvim',
        config = function()
            -- define my dashboard
            local dashboard = require 'alpha.themes.dashboard'
            dashboard.section.header.val = {
                [[ ███▄    █ ██▒   █▓ ██▓ ███▄ ▄███▓▓█████]],
                [[ ██ ▀█   █▓██░   █▒▓██▒▓██▒▀█▀ ██▒▓█   ▀]],
                [[▓██  ▀█ ██▒▓██  █▒░▒██▒▓██    ▓██░▒███]],
                [[▓██▒  ▐▌██▒ ▒██ █░░░██░▒██    ▒██ ▒▓█  ▄]],
                [[▒██░   ▓██░  ▒▀█░  ░██░▒██▒   ░██▒░▒████▒]],
                [[░ ▒░   ▒ ▒   ░ ▐░  ░▓  ░ ▒░   ░  ░░░ ▒░ ░]],
                [[░ ░░   ░ ▒░  ░ ░░   ▒ ░░  ░      ░ ░ ░  ░]],
                [[   ░   ░ ░     ░░   ▒ ░░             ░]],
                [[         ░']],
            }
            dashboard.section.buttons.val = {
                dashboard.button("e", "New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("u", "Update Plugin", ":Lazy sync<CR>"),
                dashboard.button("p", "Profile", ":Lazy profile<CR>"),
                dashboard.button("q", "Quit NVIM", ":qa<CR>")
            }
            dashboard.config.opts.noautocmd = true

            -- enable setup
            require('alpha').setup(dashboard.config)
        end
    },
    -- LSP support
    {
        -- The completion plugin
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',     -- LSP provider
            'hrsh7th/cmp-buffer',       -- buffer completions
            'hrsh7th/cmp-path',         -- path completions
            'hrsh7th/cmp-nvim-lua',     -- Lua LSP
            'L3MON4D3/LuaSnip',         -- Snippet engine
            'saadparwaiz1/cmp_luasnip', -- Snippet cmp interface
        },
        config = function()
            require("settings.cmp")
        end,
        -- load cmp on InsertEnter
        event = "InsertEnter",
    },
    -- {
    --     'lvimuser/lsp-inlayhints.nvim',
    --     branch = "anticonceal",
    --     opts   = {},
    --     lazy   = true,
    --     init   = function()
    --         vim.api.nvim_create_autocmd("LspAttach", {
    --             group = vim.api.nvim_create_augroup("LspAttach_inlayhints", {}),
    --             callback = function(args)
    --                 if not (args.data and args.data.client_id) then
    --                     return
    --                 end
    --                 local client = vim.lsp.get_client_by_id(args.data.client_id)
    --                 require("lsp-inlayhints").on_attach(client, args.buf)
    --             end,
    --         })
    --     end,
    -- },
    {
        'neovim/nvim-lspconfig', -- enable LSP
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim"
        },
    },
    -- lspconfig Adapter
    {
        'williamboman/mason.nvim',
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end,
        event = "VeryLazy"
    },
    {
        'j-hui/fidget.nvim', -- UI for LSP loading
        config = true,
        -- branch = 'legacy',
        event = "VeryLazy"
    },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require("lsp.mason-lspconfig")
        end,
        -- event = "VeryLazy",
    },
    {
        'simrat39/rust-tools.nvim', -- Rust LSP
        ft = "rust",
    },
    {
        'saecki/crates.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config       = function()
            require('crates').setup()
        end,
    },
    {
        'p00f/clangd_extensions.nvim', -- C/C++ LSP
        ft = { "c", "c++" }
    },
    -- telescope
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
    },
    -- outline
    {
        'simrat39/symbols-outline.nvim',
        config = function()
            local opts = {
                keymaps = {
                    close = { "<Esc>", "q" },
                    goto_location = "<Cr>",
                    focus_location = "<Tab>",
                    hover_symbol = "K",
                    toggle_preview = "p",
                    rename_symbol = "r",
                    code_actions = "a",
                    fold = "h",
                    unfold = "l",
                    fold_all = "W",
                    unfold_all = "E",
                    fold_reset = "R",
                },
            }
            require("symbols-outline").setup(opts)
        end,
        cmd = 'SymbolsOutline'
    },
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
    -- ssh copy/paste
    {
        'ojroques/nvim-osc52',
        config = function()
            vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, { expr = true })
            vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true })
            vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)
        end
    },
}

lazy.setup(plugins, option)
