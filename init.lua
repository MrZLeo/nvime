-- load config const
require "config"

-- load basic settings
require "base"

-- packer
require "plugins"

-- load keymap
require "keymap"

-- load theme
require "colorscheme"

-- load plugin configuration
require "lsp"
require "settings"

-- " clang-format
-- " autocmd FileType c,cpp autocmd BufWritePre * :Autoformat
