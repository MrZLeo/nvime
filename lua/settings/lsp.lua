-- ============================================================================
-- LSP Configuration - All LSP setup in one place
-- ============================================================================

-- ============================================================================
-- 1. DIAGNOSTIC CONFIGURATION
-- ============================================================================

local signs_text = {
    [vim.diagnostic.severity.ERROR] = "■",
    [vim.diagnostic.severity.WARN] = "▲",
    [vim.diagnostic.severity.HINT] = "✦",
    [vim.diagnostic.severity.INFO] = "●",
}

vim.diagnostic.config({
    virtual_text = false,
    signs = { text = signs_text },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = "always",
    },
})

-- ============================================================================
-- 2. DIAGNOSTIC DISPLAY & HOVER LOGIC
-- ============================================================================

-- State management
local state = {
    skip_diagnostic = false,
    timer = nil
}

-- Config
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

-- Cache blink.cmp require at module level (not in hot path)
local blink_cmp = require("blink.cmp")

local function is_completion_visible()
    return blink_cmp.is_visible()
end

local function display_diagnostics()
    if not is_completion_visible() then
        vim.diagnostic.open_float(nil, config.float_opts)
    end
end

-- Auto-show diagnostics on cursor hold
vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = "*",
    callback = function()
        if not state.skip_diagnostic then
            display_diagnostics()
        end
    end,
})

-- Toggle hover (temporarily suppress diagnostic float)
function ToggleHover()
    state.skip_diagnostic = true
    vim.lsp.buf.hover()

    if state.timer then state.timer:stop() end

    state.timer = vim.defer_fn(function()
        state.skip_diagnostic = false
    end, config.hover_delay)
end

-- ============================================================================
-- 3. LSP KEYMAPS
-- ============================================================================

local function setup_keymaps(bufnr)
    local maps = {
        { "n", "gD",        vim.lsp.buf.declaration },
        { "n", "gd",        require('telescope.builtin').lsp_definitions },
        { "n", "K",         ToggleHover },
        { "n", "gi",        require('telescope.builtin').lsp_implementations },
        { "n", "<Space>rn", vim.lsp.buf.rename },
        { "n", "gr",        require('telescope.builtin').lsp_references },
        { "n", "<Space>f",  vim.lsp.buf.code_action },
        { "n", "<Space>l",  require('telescope.builtin').diagnostics }
    }
    for _, map in ipairs(maps) do
        vim.keymap.set(map[1], map[2], map[3], { buffer = bufnr })
    end
end

-- ============================================================================
-- 4. AUTO-FORMAT ON SAVE
-- ============================================================================

local skip_format = {
    c = true,
    -- cpp = true
}

local function setup_format(client, bufnr)
    if not client:supports_method('textDocument/formatting') then return end
    if skip_format[vim.bo.filetype] then return end

    vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
            vim.lsp.buf.format({
                bufnr = bufnr,
                id = client.id,
                timeout_ms = 2000,
            })
        end
    })
end

-- ============================================================================
-- 5. LSP ATTACH HANDLER
-- ============================================================================

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        setup_keymaps(args.buf)
        setup_format(client, args.buf)
    end
})

-- ============================================================================
-- 6. INLAY HINTS
-- ============================================================================

vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

-- ============================================================================
-- 7. SERVER-SPECIFIC CONFIGURATIONS
-- ============================================================================

-- Clangd
vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=never",
        "--pch-storage=memory",
        "--offset-encoding=utf-16"
    },
    init_options = {
        fallbackFlags = { '--std=gnu++23' }
    },
})

-- Lua LS
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            hint = { enable = true },
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    }
})

-- Rust (via rustaceanvim plugin)
vim.g.rustaceanvim = {
    server = {
        on_attach = function(client, bufnr)
            setup_keymaps(bufnr)
        end,
        default_settings = {
            ['rust-analyzer'] = {
                inlayHints = {
                    bindingModeHints = {
                        enable = false,
                    },
                    chainingHints = {
                        enable = true,
                    },
                    closingBraceHints = {
                        enable = true,
                        minLines = 25,
                    },
                    closureReturnTypeHints = {
                        enable = "never",
                    },
                    lifetimeElisionHints = {
                        enable = "never",
                        useParameterNames = false,
                    },
                    maxLength = 25,
                    parameterHints = {
                        enable = true,
                    },
                    reborrowHints = {
                        enable = "never",
                    },
                    renderColons = true,
                    typeHints = {
                        enable = true,
                        hideClosureInitialization = false,
                        hideNamedConstructor = false,
                    },
                },
            },
        },
    },
}

-- ============================================================================
-- 8. ENABLE LSP SERVERS
-- ============================================================================

local lsp_servers = {
    "clangd",
    "lua_ls",
    "ruff",
    "pyright",
    "taplo",
    "texlab",
    "neocmake",
}

vim.lsp.enable(lsp_servers)
