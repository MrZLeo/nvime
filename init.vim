" 载入个人配置
:luafile ~/.config/nvim/config.lua

" 定义载入配置命令
command! -nargs=1 LoadScript exec 'source ' . g:config_root_path . '<args>'

" 载入基础配置
:luafile ~/.config/nvim/config/base.lua

" packer
lua require "plugins"

" 载入快捷键配置
:luafile ~/.config/nvim/config/keymap.lua

" 载入主题配置
LoadScript theme/theme.vim

" load plugin configuration
LoadScript plugins/coc-fzf.vim
LoadScript plugins/coc.nvim.vim
LoadScript plugins/fzf.vim.vim

lua require "settings.nvim-ts-rainbow"
lua require "settings.nvim-treesitter-refactor"
lua require "settings.nvim-treesitter-textobjects"
lua require "settings.nvim-treesitter"
lua require "settings.todo-comments"
lua require "settings.vgit"
lua require "settings.chadtree"
lua require "settings.lualine"
lua require "settings.nvim-autopairs"

