-- init.lua - minimal single-file Neovim config
-- Requirements: Neovim 0.10+
-- Features: LSP (nvim-lspconfig), blink.cmp completion, basic keymaps
-- basic configuration
-- 1. Bootstrap lazy.nvim ----------------------------------------------------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- 2. Plugins ----------------------------------------------------------------
require("lazy").setup({
    { "neovim/nvim-lspconfig" },
    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = { 'rafamadriz/friendly-snippets' },
        version = 'v0.*', -- Use for stability;
        -- build = 'cargo build --release',
        opts = {
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
                default = { "lsp", "path", "snippets", "buffer" },
            },
            cmdline = { enabled = false },

            signature = { enabled = true },

            completion = {
                documentation = { auto_show = true },
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        "saghen/blink.pairs",
        version = "*",
        build = 'cargo build --release',
        opts = {
            mappings = {
                -- you can call require("blink.pairs.mappings").enable() and
                -- require("blink.pairs.mappings").disable() to enable/disable
                -- mappings at runtime
                enabled = true,
                -- cmdline = true,
                -- or disable with `vim.g.pairs = false` (global) and
                -- `vim.b.pairs = false` (per-buffer) and/or with
                -- `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
                disabled_filetypes = {},
                -- see the defaults:
                -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
                pairs = {}
            },
            highlights = {
                enabled = true,
                -- requires require('vim._extui').enable({}), otherwise has no
                -- effect
                -- cmdline = true,
                groups = {
                    'BlinkPairsOrange',
                    'BlinkPairsPurple',
                    'BlinkPairsBlue'
                },
                -- unmatched_group = 'BlinkPairsUnmatched',

                -- highlights matching pairs under the cursor
                matchparen = {
                    enabled = true,
                    -- known issue where typing won't update matchparen highlight,
                    -- disabled by default
                    -- cmdline = false,
                    group = 'BlinkPairsMatchParen'
                },
            },
            debug = false
        }
    },
    {
        'j-hui/fidget.nvim', -- UI for LSP loading
        opts = {}
    },
}, { ui = { border = "rounded" } })

-- 3. Basic Settings ---------------------------------------------------------
local default_option = {
    compatible = false,     -- nocompatible with vi
    fileencoding = "utf-8", -- coding format utf-8
    number = true,
    relativenumber = true,
    smartindent = true,
    autoindent = true,
    linebreak = true,
    backup = false,
    swapfile = false,
    writebackup = false,
    hidden = true,
    ignorecase = true, -- ignore case when use '/' to search
    smartcase = true,  -- if enter uppercase, don't ignore case
    history = 500,
    splitbelow = true,
    expandtab = true,
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    smarttab = true,
    shiftround = true,
    autoread = true,
    confirm = true,
    showmode = false,
    timeoutlen = 500,
    updatetime = 100,
    mouse = "a",
    lazyredraw = true,
    cmdheight = 1,
    showmatch = true,
    matchtime = 2,
    clipboard = "unnamedplus",
    signcolumn = "yes", -- prevent shaking when using LSP
    syntax = "on",
    termguicolors = true,
    incsearch = true, -- increase search feedback
    cursorline = true,
    -- colorcolumn = "100",
    pumheight = 20,
    pumblend = 20,

    -- use smart fold
    foldmethod = "expr",
    foldlevel = 20,
    foldexpr = "nvim_treesitter#foldexpr()",
}

-- enable all setting
for k, v in pairs(default_option) do
    vim.opt[k] = v
end

local function paste()
    return {
        vim.fn.split(vim.fn.getreg(""), "\n"),
        vim.fn.getregtype(""),
    }
end

vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
        ["+"] = paste,
        ["*"] = paste,
    },
}

-- latex support
vim.g.tex_flavor = 'latex'
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.tex" },
    command = [[set spell]]
})

-- neovim cannot detect gn format right now
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.gn", "*.gni" },
    command = "set filetype=gn",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.ets" },
    command = "set filetype=typescript",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.h" },
    command = "set filetype=c",
})

-- CSV
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.csv" },
    callback = function()
        vim.cmd [[set colorcolumn=]]
        vim.cmd [[CsvViewEnable]]
    end
})

-- 4. Keymaps ----------------------------------------------------------------
local map = vim.keymap.set
map({ "n", "i" }, "<C-s>", function() vim.cmd.write() end, { desc = "Save buffer" })
map("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })
map("n", "<leader>w", vim.cmd.write, { desc = "Write" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })

-- 5. LSP Setup --------------------------------------------------------------
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

-- DON'T auto format
local skip_file_type = { "c", "cpp" }

local function is_skip_format(filetype)
    for _, pattern in ipairs(skip_file_type) do
        if filetype == pattern then
            return true
        end
    end
    return false
end

local function lsp_setup_format(client, buf)
    if not client:supports_method('textDocument/formatting') then return end

    if not is_skip_format(vim.bo.filetype) then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = buf,
            callback = function()
                vim.lsp.buf.format({
                    bufnr = buf,
                    id = client.id,
                    timeout_ms = 2000,
                })
            end
        })
    end
end

---@diagnostic disable-next-line: unused-local
local function lsp_setup_onattach(client, bufnr)
    -- State management
    local state = {
        skip_diagnostic = false,
        timer = nil
    }

    -- Configuration
    local config = {
        float_opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        },
        hover_delay = 1000
    }

    -- Core functions: Display diagnostics and toggle hover
    local function is_completion_visible()
        return require("blink.cmp").is_visible()
    end

    local function display_diagnostics()
        if not is_completion_visible() then
            vim.diagnostic.open_float(nil, config.float_opts)
        end
    end

    -- Setup diagnostic display
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        pattern = "*",
        callback = function()
            if not state.skip_diagnostic then
                display_diagnostics()
            end
        end,
    })

    function ToggleHover()
        state.skip_diagnostic = true
        vim.lsp.buf.hover()

        if state.timer then state.timer:stop() end

        state.timer = vim.defer_fn(function()
            state.skip_diagnostic = false
        end, config.hover_delay)
    end

    local function setup_keymaps(bufnr)
        -- See `:help vim.lsp.buf` for more.
        local opts = { buffer = bufnr, noremap = true, silent = true }
        local map = vim.keymap.set

        map("n", "gD", vim.lsp.buf.declaration, opts)
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "K", ToggleHover, opts)
        map("n", "gi", vim.lsp.buf.implementation, opts)
        map("n", "<Space>rn", vim.lsp.buf.rename, opts)
        map("n", "gr", vim.lsp.buf.references, opts)
        map("n", "<Space>ca", vim.lsp.buf.code_action, opts)
        map("n", "<Space>e", vim.diagnostic.open_float, opts)
    end
    setup_keymaps(bufnr)
end

local function lsp_setup(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    lsp_setup_format(client, args.buf)
    lsp_setup_onattach(client, args.buf)
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        lsp_setup(args)
    end
})

-- Enable inlay hints
vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

local lsp_server = {
    "clangd",
    "lua_ls",
    -- "ruff",
    -- "pyright",
    -- "ty",
    -- "taplo",
    -- "texlab",
    -- "neocmake",
}

vim.lsp.enable(lsp_server)
vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--query-driver=/usr/sbin/gcc",
        "--completion-style=detailed",
        -- "--malloc-trim",
        "--header-insertion=never",
        "--pch-storage=memory",
        -- "--offset-encoding=utf-16"
    },
    init_options = {
        fallbackFlags = { '--std=gnu++23' }
    },
})


-- 7. Optional: basic colorscheme -------------------------------------------
vim.cmd.colorscheme("default")

-- Done. Open a file and start coding! ---------------------------------------
