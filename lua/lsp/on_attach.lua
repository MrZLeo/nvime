local M = {}

-- 自定义变量来跟踪悬浮窗口状态
vim.b.lsp_hover_doc_shown = false

-- 自定义函数来显示诊断信息
local function show_diagnostics()
    local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor', -- 仅显示光标下的错误
    }
    vim.diagnostic.open_float(nil, opts)
end

-- 设置LSP的诊断信息自动弹出
local function lsp_diagnostics_autopopup(client)
    if client.server_capabilities.document_highlight then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            pattern = "*",
            callback = function()
                show_diagnostics()
            end,
        })
    end
end

-- 定义切换悬浮窗口显示的函数
function ToggleHoverDoc()
    vim.lsp.buf.hover()
end

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
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
    lsp_diagnostics_autopopup(client)
end

return M
