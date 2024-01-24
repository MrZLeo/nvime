---@diagnostic disable:unused-function
---@diagnostic disable:lowercase-global

--- Delete buffers number over x
--
---@param x integer buffer number
function delete_buffer_over_x(x)
    local buf_begin = 1
    if x < buf_begin then
        vim.notify("x should bigger than 0")
    end

    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_number(buf) > x then
            vim.api.nvim_buf_delete(buf)
        end
    end
end
