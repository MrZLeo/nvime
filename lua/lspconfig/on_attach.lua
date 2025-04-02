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

function ToggleHover()
    state.skip_diagnostic = true
    vim.lsp.buf.hover()

    if state.timer then state.timer:stop() end

    state.timer = vim.defer_fn(function()
        state.skip_diagnostic = false
    end, config.hover_delay)
end

-- LSP setup
local M = {}

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

-- Setup diagnostic display
vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = "*",
    callback = function()
        if not state.skip_diagnostic then
            display_diagnostics()
        end
    end,
})

---@diagnostic disable-next-line: unused-local
M.on_attach = function(client, bufnr)
    setup_keymaps(bufnr)
end

return M
