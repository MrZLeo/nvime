-- some macros from vim
local vimrc = vim.env.MYVIMRC
local home = vim.env.HOME

-- root dir of $vimrc
vim.g.vim_root_path = vim.fn.fnamemodify(vimrc, ':h') .. '/'
local root = vim.g.vim_root_path

-- config root dir
vim.g.config_root_path = root .. 'config/'
local config = vim.g.config_root_path

-- plugin dir
vim.g.plugins_config_root_path = config .. 'plugins/'
vim.g.other_config_root_path = config .. 'other/'

-- cache
vim.g.cache_root_path = home .. '/.cache/vim/'
local cache = vim.g.cache_root_path

-- plugin install path
vim.g.plugins_install_path = cache .. 'plugins/'

-- script
vim.g.scripts_root_path = root .. '/scripts/'
