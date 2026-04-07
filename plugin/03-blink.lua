vim.pack.add({
    -- optional: provides snippets for the snippet source
    "https://github.com/rafamadriz/friendly-snippets",

    -- common lib for blink
    "https://github.com/saghen/blink.lib",

    -- cmp
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range('*')
    },

    -- pairs
    {
        src = "https://github.com/saghen/blink.pairs",
        version = vim.version.range('*')
    },
})

require("blink.cmp").setup({
    keymap = {
        preset = 'enter',
        ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['C-w'] = { 'snippet_forward', 'fallback' },
        ['C-e'] = { 'snippet_backward', 'fallback' },
    },

    appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = true,
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer", },
    },
    cmdline = { enabled = false },

    signature = { enabled = true },

    completion = {
        documentation = { auto_show = true },
    },

})

require("blink.pairs").setup({
    mappings = {
        enabled = true,
        disabled_filetypes = {},
        pairs = {},
    },
    highlights = {
        enabled = true,
        groups = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterGreen",
            "RainbowDelimiterCyan",
            "RainbowDelimiterBlue",
            "RainbowDelimiterViolet",
            "RainbowDelimiterGreen",
        },
    },
    debug = false,
})
