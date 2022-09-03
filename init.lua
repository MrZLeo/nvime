-- load config const
require "config"

-- use for load vim script
-- vim.cmd [[command! -nargs=1 LoadScript exec 'source ' . g:config_root_path . '<args>']]

-- load basic settings
require "base"

-- packer
require "plugins"

-- load keymap
require "keymap"

-- load theme
require "colorscheme"

-- load plugin configuration

-- vim.cmd [[ LoadScript plugins/coc-fzf.vim ]]
-- vim.cmd [[ LoadScript plugins/coc.nvim.vim ]]
-- vim.cmd [[ LoadScript plugins/fzf.vim.vim ]]

require "lsp"
require "settings"

-- " clang-format
-- " autocmd FileType c,cpp autocmd BufWritePre * :Autoformat
