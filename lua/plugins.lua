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
    -- Make lua_ls knows about neovim
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    -- surrounding
    {
        'kylechui/nvim-surround',
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = true,
        event = "BufReadPre",
    },
    -- color theme
    {
        'sainnhe/edge',
        lazy = false
    },
    -- rainbow brackets
    {
        'HiPhish/rainbow-delimiters.nvim',
        config = function()
            local rainbow_delimiters = require('rainbow-delimiters')
            require('rainbow-delimiters.setup').setup({
                strategy = {
                    [''] = rainbow_delimiters.strategy['global'],
                    vim = rainbow_delimiters.strategy['local'],
                },
                query = {
                    [''] = 'rainbow-delimiters',
                },
                priority = {
                    [''] = 110,
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterCyan",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterGreen",
                },
            })
        end
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
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            columns = {
                "icon",
                -- "permissions",
                -- "size",
                -- "mtime",
            },
            view_options = {
                show_hidden = true
            },
        },
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
        event = "InsertEnter"
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
    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = { 'rafamadriz/friendly-snippets' },
        -- version = 'v0.*', -- Use for stability;
        build = 'cargo build --release',
        opts = {
            keymap = {
                preset = 'enter',
                ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
            },

            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- will be removed in a future release
                use_nvim_cmp_as_default = true,
            },

            sources = {
                providers = {
                    copilot = {
                        name = "copilot",
                        module = "blink-cmp-copilot",
                        score_offset = 100,
                        async = true,
                    },
                },
                cmdline = {},

                default = { "lsp", "path", "snippets", "buffer", "copilot" },
            },

            signature = { enabled = true }
        },
        opts_extend = { "sources.default" },
    },
    {
        'neovim/nvim-lspconfig', -- enable LSP
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            'hrsh7th/nvim-cmp',
            'saghen/blink.cmp',
        },
        opts = {
            servers = {
                lua_ls = require("lsp.lua"),
                clangd = require("lsp.clangd").opt,
                taplo = {},
                texlab = {},
                neocmake = {},
                zls = {}
            }
        },
        config = function(_, opts)
            local lspconfig = require('lspconfig')
            local on_attach = require('lsp.on_attach').on_attach
            for server, config in pairs(opts.servers) do
                config.capabilities = require('blink.cmp').get_lsp_capabilities()
                config.on_attach = on_attach
                lspconfig[server].setup(config)
            end
        end
    },
    {
        'j-hui/fidget.nvim', -- UI for LSP loading
        opts = {
            -- options
        }
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false,   -- This plugin is already lazy
    },
    {
        'saecki/crates.nvim',
        tag = 'stable',
        config = function()
            require('crates').setup({})
        end,
        event = { "BufRead Cargo.toml" },
    },
    {
        'p00f/clangd_extensions.nvim', -- C/C++ LSP
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        ft = { "c", "c++" },
        opt = require("lsp.clangd").ext,
        config = function(_, opt)
            require('clangd_extensions').setup(opt)
        end
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
        "giuxtaposition/blink-cmp-copilot",
        dependencies = 'zbirenbaum/copilot.lua'
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
