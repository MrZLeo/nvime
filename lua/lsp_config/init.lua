-- LSP manager
require("lsp_config.diagnostic")
require("lsp_config.rust")

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
    require('lsp_config.on_attach').on_attach(client, bufnr)
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
    "ruff",
    "pyright",
    -- "ty",
    "taplo",
    "texlab",
    "neocmake",
}

vim.lsp.enable(lsp_server)

-- Loop through each server and try to load its specific configuration
for _, server in ipairs(lsp_server) do
    pcall(require, "lsp_config.lsp." .. server)
end
