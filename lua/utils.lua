---@diagnostic disable:unused-function
---@diagnostic disable:lowercase-global

--- Delete buffers except current
function clean_buf()
    cur = vim.api.nvim_buf_get_name(0)

    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_name(buf) ~= cur then
            vim.api.nvim_buf_delete(buf, {})
        end
    end
end
