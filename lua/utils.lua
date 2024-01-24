---@diagnostic disable:unused-local
---@diagnostic disable:unused-function

local function delete_buffers_over_x(x)
    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_number(buf) > x then
            vim.api.nvim_buf_delete(buf)
        end
    end
end
