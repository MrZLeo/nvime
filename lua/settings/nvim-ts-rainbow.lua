local config = {
    rainbow = {
        enable = true,
        extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    }
}

-- enable settings
require 'nvim-treesitter.configs'.setup(config)

-- FIXME patch: rainbow will be wrong, use this command to reset
--              but it maybe failed, if fail, just restart the nvim
vim.keymap.set('n', '<Space>e',
    ':TSDisable rainbow | TSEnable rainbow<CR>', { silent = true })
