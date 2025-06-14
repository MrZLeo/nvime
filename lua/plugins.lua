-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

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
        -- 'MrZLeo/blink.pairs',

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
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
    -- color
    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = { -- set to setup table
        },
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
        dependencies = { 'rafamadriz/friendly-snippets' },
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
                },

                default = { "lsp", "path", "snippets", "buffer", "copilot", },
            },
            cmdline = { enabled = false },

            signature = { enabled = true },

            completion = {
                documentation = { auto_show = true },
            },
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
        "olimorris/codecompanion.nvim",
        opts = {
            send_code = false,
            strategies = {
                chat = {
                    adapter = {
                        name = "copilot",
                        model = "gemini-2.5-pro",
                    },
                },
                inline = {
                    adapter = {
                        name = "copilot",
                        model = "claude-sonnet-4",
                    },
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "j-hui/fidget.nvim"
        },
        init = function()
            require("settings.codecompanion"):init()
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
        opts = {
            parser = { comments = { "#", "//" } },
        },
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
        ft = { "csv" },
    },
    -- LSP
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lsp_config")
        end
    }
}

require("lazy").setup({
    spec = plugins,
    -- automatically check for plugin updates
    -- checker = { enabled = true }
})
