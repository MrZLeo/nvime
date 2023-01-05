-- improve performance
require "performance"
-- load impatient before all plugins
require('impatient')

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
