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
        event = "BufReadPre",
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
    -- count the hightlight
    {
        'kevinhwang91/nvim-hlslens',
        config = true,
        event = "InsertEnter",
    },
    -- indent line
    { 'lukas-reineke/indent-blankline.nvim', event = "BufReadPre" },
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
        },
        lazy = true
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

            -- when started
            vim.api.nvim_create_autocmd(
                { "User" },
                {
                    pattern = "AlphaReady",
                    command = "echo 'ready'"
                }
            )
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
            'onsails/lspkind.nvim',     -- LSP icons
        },
        config = function()
            require("settings.cmp")
        end,
        -- load cmp on InsertEnter
        event = "InsertEnter",
    },
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
        opts = {
            -- options
        }
    },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require("lsp.mason-lspconfig")
        end,
        event = "VeryLazy",
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false,   -- This plugin is already lazy
    },
    {
        'saecki/crates.nvim',
        tag = 'stable',
        event = { "BufRead Cargo.toml" },
        config = function()
            require('crates').setup()
        end,
    },
    {
        'p00f/clangd_extensions.nvim', -- C/C++ LSP
        ft = { "c", "c++" }
    },
    -- outline
    {
        'hedyhli/outline.nvim',
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = { -- Example mapping to toggle outline
            { "<Space>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {
            keymaps = {
                close = { "<Esc>", "q" },
                code_actions = "a",
                fold = "h",
                fold_all = "W",
                fold_reset = "R",
                goto_location = "<Cr>",
                hover_symbol = "K",
                peek_location = "<Tab>",
                rename_symbol = "r",
                toggle_preview = "p",
                unfold = "l",
                unfold_all = "E"
            }
        }
    },
    -- for symbols searching
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('telescope').setup {
                defaults = {
                    initial_mode = "normal"
                }
            }
        end
    },
    {
        "MysticalDevil/inlay-hints.nvim",
        event = "LspAttach",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            require("inlay-hints").setup()
        end
    },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    },
    {
        "zbirenbaum/copilot.lua",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = false,
                    -- auto_trigger = true,
                    -- keymap = {
                    --     accept = "<Tab>",
                    --     dismiss = "<C-]"
                    -- },
                },
                panel = {
                    enabled = false
                }
            })
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        config = function()
            require("copilot_cmp").setup()
        end
    },
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false, -- set this if you want to always pull the latest change
        opts = {
            provider = "openai",
            openai = {
                endpoint = "http://ipads.chat.gpt:3006/v1",
                model = "claude-3-5",
                -- model = "gpt-4o-2024-08-06",
                -- model = "o1-mini",
                temperature = 0,
                max_tokens = 4096,
            },
            behaviour = {
                auto_suggestions = false, -- Experimental stage
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    }

}

lazy.setup(plugins, option)
