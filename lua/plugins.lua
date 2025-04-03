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
        lazy = false,
        priority = 1000,
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.edge_enable_italic = false
            vim.g.edge_better_performance = 1
            vim.g.edge_menu_selection_background = 'green'
            vim.api.nvim_create_autocmd('ColorScheme', {
                group = vim.api.nvim_create_augroup('custom_highlights_edge', {}),
                pattern = 'edge',
                callback = function()
                    local config = vim.fn['edge#get_configuration']()
                    local palette = vim.fn['edge#get_palette'](config.style, config.dim_foreground,
                        config.colors_override)
                    local set_hl = vim.fn['edge#highlight']

                    set_hl('DiffText', palette.none, palette.diff_blue)
                end
            })

            vim.cmd.colorscheme('edge')
        end

    },
    -- rainbow brackets
    {
        'saghen/blink.pairs',

        build = 'cargo build --release',
        branch = 'main',

        --- @module 'blink.pairs'
        --- @type blink.pairs.Config
        opts = {
            mappings = {
                enabled = true,
                -- see the defaults: https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L10
                pairs = {},
            },
            highlights = {
                enabled = true,
                groups = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterCyan",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterGreen",
                },
            },
            debug = false,
        }
    },
    -- treesitter
    { 'nvim-treesitter/nvim-treesitter',     build = ':TSUpdate' },
    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
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
                [[         ░]],
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
    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = { 'rafamadriz/friendly-snippets', 'Kaiser-Yang/blink-cmp-avante', },
        version = 'v0.*', -- Use for stability;
        -- build = 'cargo build --release',
        opts = {
            keymap = {
                preset = 'enter',
                ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
                ['C-w'] = { 'snippet_forward', 'fallback' },
                ['C-e'] = { 'snippet_backward', 'fallback' },
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
                    avante = {
                        module = 'blink-cmp-avante',
                        name = 'Avante',
                        opts = {
                            -- options for blink-cmp-avante
                        }
                    }
                },

                default = { "avante", "lsp", "path", "snippets", "buffer", "copilot", },
            },
            cmdline = { enabled = false },

            signature = { enabled = true }
        },
        opts_extend = { "sources.default" },
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
        -- branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' },
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
            -- custom vendors
            vendors = {
                deepseek = {
                    __inherited_from = "openai",
                    api_key_name = "DEEPSEEK_API_KEY",
                    endpoint = "https://api.deepseek.com",
                    model = "deepseek-chat",
                    temperature = 0,
                    timeout = 1800
                },
                siliconflow = {
                    __inherited_from = "openai",
                    api_key_name = "SILICONFLOW_API_KEY",
                    endpoint = "https://api.siliconflow.com/v1",
                    model = "deepseek-ai/DeepSeek-R1",
                    temperature = 0.6,
                    disable_tools = true,
                    timeout = 1800
                },
                ["qwen-max-latest"] = {
                    __inherited_from = "openai",
                    api_key_name = "QWEN_API_KEY",
                    endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
                    temperature = 0,
                    model = "qwen-max-latest",
                },
                ["qwen-deepseek-r1"] = {
                    __inherited_from = "openai",
                    api_key_name = "QWEN_API_KEY",
                    endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
                    temperature = 0,
                    model = "deepseek-r1",
                },
                doubao = {
                    __inherited_from = "openai",
                    api_key_name = "DOUBAO_API_KEY",
                    endpoint = "https://ark.cn-beijing.volces.com/api/v3",
                    model = "ep-20250213170236-5xttd",
                    timeout = 1800
                }
            },
            -- normal setting
            openai = {
                endpoint = "http://ipads.chat.gpt:3006/v1",
                model = "claude-3-5",
            },
            copilot = {
                model = "claude-3.7-sonnet-thought",
                temperature = 1,
                max_tokens = 20000
            },
            behaviour = {
                auto_suggestions = false, -- Experimental stage
                -- enable_cursor_planning_mode = true
            },
            provider = "copilot",
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
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
    -- im-select
    {
        "keaising/im-select.nvim",
        config = function()
            require("im_select").setup({})
        end,
    },
    -- comments
    {
        'numToStr/Comment.nvim',
        opts = {}
    },
    -- CSV
    {
        "hat0uma/csvview.nvim",
        ---@module "csvview"
        ---@type CsvView.Options
        opts = {
            parser = { comments = { "#", "//" } },
        },
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
        ft = { "csv" },
    }
}

lazy.setup(plugins, option)
