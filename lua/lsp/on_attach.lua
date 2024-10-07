-- Initialize control flags
local skip_diagnostic_float = false
local diagnostic_timer = nil

-- Function to check if nvim-cmp's completion menu is visible
local function is_cmp_visible()
    local cmp = require('cmp')
    return cmp.visible()
end

-- Custom function to display diagnostic information
local function show_diagnostics()
    -- Only show diagnostics if nvim-cmp's completion menu is not visible
    if not is_cmp_visible() then
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor', -- Only show errors under the cursor
        }
        vim.diagnostic.open_float(nil, opts)
    end
end

-- Set LSP diagnostic information to pop up automatically
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    pattern = "*",
    callback = function()
        if not skip_diagnostic_float then
            show_diagnostics()
        end
    end,
})

-- Define a function to toggle the hover window display
function ToggleHoverDoc()
    -- Set the flag to skip displaying the diagnostic floating window
    skip_diagnostic_float = true

    -- Show function documentation
    vim.lsp.buf.hover()

    -- If there is an existing timer, stop it first
    if diagnostic_timer then
        diagnostic_timer:stop()
    end

    -- Set a timer to reset the flag after 1 second
    diagnostic_timer = vim.defer_fn(function()
        skip_diagnostic_float = false
    end, 1000) -- Reset after 1 second (1000 milliseconds)
end

local M = {}

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K",
        "<cmd>lua ToggleHoverDoc()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Space>f", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Space>l", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
    return
end

M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

M.on_attach = function(client, bufnr)
    lsp_keymaps(bufnr)
end

return M
