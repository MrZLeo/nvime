-- define signs
local signs_text = {
    [vim.diagnostic.severity.ERROR] = "■",
    [vim.diagnostic.severity.WARN] = "▲",
    [vim.diagnostic.severity.HINT] = "✦",
    [vim.diagnostic.severity.INFO] = "●",
}

-- define diagnostic
local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
        text = signs_text,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = "always",
    },
}

vim.diagnostic.config(config)
