local fn = vim.fn

-- Automatically install packer
local install_path = "/Users/mrzleo/.local/share/nvim/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
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
    use "wbthomason/packer.nvim"  -- Have packer manage itself
    use "tpope/vim-surround"      -- surrounding
    use 'p00f/nvim-ts-rainbow'    -- rainbow bracket
    use 'sainnhe/edge'            -- theme
    use 'nvim-treesitter/nvim-treesitter-refactor'
    use 'romgrk/nvim-treesitter-context'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'yianwillis/vimcdoc'
    use 'kevinhwang91/nvim-hlslens'
    use 'tpope/vim-commentary'
    use 'nvim-lua/plenary.nvim'
    use 'folke/todo-comments.nvim'
    use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }
    -- use 'glepnir/indent-guides.nvim' -- indent line
    use "lukas-reineke/indent-blankline.nvim"
    use 'tanvirtin/vgit.nvim'
    use 'norcalli/nvim-colorizer.lua'
    use { 'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps' }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- remove space in the end of line
    use 'lukoshkin/trailing-whitespace'

    -- pair brackets
    use "windwp/nvim-autopairs"


    -- startup page
    use {
        "goolord/alpha-nvim",
        config = function ()
            local alpha = require'alpha'
            local dashboard = require'alpha.themes.dashboard'
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
                dashboard.button( "e", "New file" , ":ene <BAR> startinsert <CR>"),
                dashboard.button( "q", "Quit NVIM" , ":qa<CR>"),
                dashboard.button( "u", "Update Plugin", ":PackerSync<CR>" ),
                dashboard.button( "s", "Start Time", ":StartupTime<CR>" )
            }
            local handle = io.popen('fortune')
            local fortune = handle:read("*a")
            handle:close()
            dashboard.section.footer.val = fortune
            dashboard.config.opts.noautocmd = true
            vim.cmd[[autocmd User AlphaReady echo 'ready']]
            alpha.setup(dashboard.config)
        end

    }
    -- coc & fzf
    use { 'neoclide/coc.nvim',  branch = 'release'  }
    use { 'antoinemadec/coc-fzf',  branch = 'release' }
    use {'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
    use 'junegunn/fzf.vim'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
