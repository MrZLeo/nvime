--- Delete buffers except active ones
local function clean_buf()
    -- Get all active window buffers
    local active_bufs = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        active_bufs[buf] = true
    end

    -- Delete all inactive buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if not active_bufs[buf] then
            -- Only delete if buffer exists and is loaded
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                local success = pcall(vim.api.nvim_buf_delete, buf, { force = false })
                if not success then
                    vim.notify("Failed to delete buffer " .. buf, vim.log.levels.WARN)
                end
            end
        end
    end
end

-- Create user command with description
vim.api.nvim_create_user_command('Clear', clean_buf, {
    desc = "Delete all buffers except active ones"
})
