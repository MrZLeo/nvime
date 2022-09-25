local fn = vim.fn

-- Automatically install packer
local install_path = "~/.local/share/nvim/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git",
        "clone",
        "--depth", "1", "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
    augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
    augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Install your plugins here
return packer.startup(function(use)
    -- My plugins here
    use 'wbthomason/packer.nvim' -- Have packer manage itself

    -- surrounding
    use({
        'kylechui/nvim-surround',
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })
    use 'p00f/nvim-ts-rainbow' -- rainbow bracket
    use 'sainnhe/edge' -- theme

    -- treesitter
    use 'nvim-treesitter/nvim-treesitter-refactor'
    use 'romgrk/nvim-treesitter-context'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'yianwillis/vimcdoc'

    -- count the hightlight
    use 'kevinhwang91/nvim-hlslens'

    -- comment
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    use 'nvim-lua/plenary.nvim'

    -- todo in comment
    use {
        'folke/todo-comments.nvim',
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup {
                signs = true, -- show icons in the signs column
                sign_priority = 8, -- sign priority
                -- keywords recognized as todo comments
                keywords = {
                    FIX = {
                        icon = " ", -- icon used for the sign, and in search results
                        color = "error", -- can be a hex color, or a named color (see below)
                        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                        -- signs = false, -- configure signs for some keywords individually
                    },
                    TODO = { icon = " ", color = "info" },
                    HACK = { icon = " ", color = "warning" },
                    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                },
                merge_keywords = true, -- when true, custom keywords will be merged with the defaults
                -- highlighting of the line containing the todo comment
                -- * before: highlights before the keyword (typically comment characters)
                -- * keyword: highlights of the keyword
                -- * after: highlights after the keyword (todo text)
                highlight = {
                    before = "", -- "fg" or "bg" or empty
                    keyword = "bg", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
                    after = "fg", -- "fg" or "bg" or empty
                    pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
                    comments_only = true, -- uses treesitter to match keywords in comments only
                    max_line_len = 400, -- ignore lines longer than this
                    exclude = {}, -- list of file types to exclude highlighting
                },
                -- list of named colors where we try to extract the guifg from the
                -- list of hilight groups or use the hex color if hl not found as a fallback
                colors = {
                    error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                    warning = { "DiagnosticWarning", "WarningMsg", "#FBBF24" },
                    info = { "DiagnosticInfo", "#2563EB" },
                    hint = { "DiagnosticHint", "#10B981" },
                    default = { "Identifier", "#7C3AED" },
                },
                search = {
                    command = "rg",
                    args = {
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                    },
                    -- regex that will be used to match keywords.
                    -- don't replace the (KEYWORDS) placeholder
                    pattern = [[\b(KEYWORDS):]], -- ripgrep regex
                    -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
                },
            }
        end
    }

    -- start time
    use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }

    -- indent line
    use 'lukas-reineke/indent-blankline.nvim'

    -- git
    use 'tanvirtin/vgit.nvim'

    -- color
    use 'norcalli/nvim-colorizer.lua'

    -- file explorer
    use { 'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps' }

    -- status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- remove space in the end of line
    use 'ntpeters/vim-better-whitespace'

    -- pair brackets
    use 'windwp/nvim-autopairs'


    -- startup page
    use 'goolord/alpha-nvim'

    -- LSP support
    use 'hrsh7th/nvim-cmp' -- The completion plugin
    use 'hrsh7th/cmp-buffer' -- buffer completions
    use 'hrsh7th/cmp-path' -- path completions
    use 'neovim/nvim-lspconfig' -- enable LSP
    use 'hrsh7th/cmp-nvim-lsp' -- LSP provider
    use 'simrat39/rust-tools.nvim' -- Rust LSP
    use 'L3MON4D3/LuaSnip' -- Snippet engine
    use 'saadparwaiz1/cmp_luasnip' -- Snippet cmp interface
    use 'hrsh7th/cmp-nvim-lua' -- Lua LSP
    use 'p00f/clangd_extensions.nvim' -- C/C++ LSP
    use 'williamboman/mason.nvim' -- LSP installer
    use 'williamboman/mason-lspconfig.nvim' -- lspconfig Adapter
    use 'j-hui/fidget.nvim' -- UI for LSP loading

    --telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use { 'stevearc/dressing.nvim' }

    -- outline
    use 'simrat39/symbols-outline.nvim'

    -- improve performance
    use 'nathom/filetype.nvim'
    use 'lewis6991/impatient.nvim'

    -- special format plugin for clang-format
    -- use 'vim-autoformat/vim-autoformat'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
