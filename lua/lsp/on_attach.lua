local M = {}

local function lsp_highlight_document(client)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
                augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                augroup END
            ]],
            false
        )
    end
end

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
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
    lsp_highlight_document(client)
    -- if client.server_capabilities.inlayHintProvider then
    --     vim.lsp.inlay_hint(bufnr, true)
    -- end

    -- vim.api.nvim_create_autocmd("InsertEnter", {
    --     buffer = bufnr,
    -- if client.server_capabilities.inlayHintProvider then
    --     vim.g.inlay_hints_visible = true
    --     vim.lsp.inlay_hint(bufnr, true)
    -- else
    --     print("no inlay hints available")
    -- end
    --     group = "lsp_augroup",
    -- })
end

M.rust_on_attach = function(client, bufnr)
    lsp_keymaps(bufnr)
    lsp_highlight_document(client)

    vim.api.nvim_create_autocmd({ 'VimEnter' }, {
        callback = function() vim.lsp.buf.inlay_hint(0, true) end,
    })
end


return M
