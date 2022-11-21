local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
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
    })

    -- rainbow and colorscheme
    use 'p00f/nvim-ts-rainbow' -- rainbow bracket
    use 'sainnhe/edge' -- theme

    -- treesitter
    use 'nvim-treesitter/nvim-treesitter-refactor'
    use 'romgrk/nvim-treesitter-context'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'yianwillis/vimcdoc'

    -- count the hightlight
    use {
        'kevinhwang91/nvim-hlslens',
        config = function()
            require('hlslens').setup()
        end
    }

    -- comment
    use 'numToStr/Comment.nvim'


    use 'nvim-lua/plenary.nvim'

    -- start time
    use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }

    -- indent line
    use { 'lukas-reineke/indent-blankline.nvim', event = "BufReadPre" }

    -- git
    use { 'tanvirtin/vgit.nvim',
        -- opt = true,
        config = function()
            require('vgit').setup()
        end }

    -- color
    use 'norcalli/nvim-colorizer.lua'

    -- file explorer
    use { 'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps', cmd = 'CHADopen' }

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
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use { 'stevearc/dressing.nvim' }

    -- outline
    use 'simrat39/symbols-outline.nvim'

    -- improve performance
    use 'nathom/filetype.nvim'
    use 'lewis6991/impatient.nvim'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
