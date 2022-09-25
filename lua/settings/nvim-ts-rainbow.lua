local config = {
    rainbow = {
        enable = true,
        extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    }
}

-- enable settings
require 'nvim-treesitter.configs'.setup(config)
