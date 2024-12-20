-- LSP manager
require("lsp.settings")
require("lsp.rust")

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

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        if not client.supports_method('textDocument/formatting') then return end


        if not is_skip_format(vim.bo.filetype) then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({
                        bufnr = args.buf,
                        id = client.id,
                        timeout_ms = 2000,
                    })
                end
            })
        end

        vim.keymap.set('v', 'ff',
            function()
                vim.lsp.buf.format({
                    range = {
                        vim.fn.getpos("'<"),
                        vim.fn.getpos("'>")
                    }
                })
                -- Exit visual mode
                vim.api.nvim_input('<Esc>')
            end,
            { silent = true }
        )
    end
})

vim.cmd('hi link LspInlayHint Comment')
