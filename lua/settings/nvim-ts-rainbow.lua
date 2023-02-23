-- FIXME patch: rainbow will be wrong, use this command to reset
--              but it maybe failed, if fail, just restart the nvim
vim.keymap.set('n', '<Space>e',
    ':TSDisable rainbow | TSEnable rainbow<CR>', { silent = true })
