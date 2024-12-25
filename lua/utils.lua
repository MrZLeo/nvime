-- Deletes all buffers that are not currently displayed in any window.
-- The function performs the following steps:
-- 1. Collects all buffers that are currently visible in windows
-- 2. Iterates through all buffers and deletes those that are:
--    - Not currently visible in any window
--    - Valid and loaded
-- @function clean_buf
local function clean_buf()
    local active_bufs = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        active_bufs[buf] = true
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if not active_bufs[buf] then
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                local success = pcall(vim.api.nvim_buf_delete, buf, { force = false })
                if not success then
                    vim.notify("Failed to delete buffer " .. buf, vim.log.levels.WARN)
                end
            end
        end
    end
end

vim.api.nvim_create_user_command('Clear', clean_buf, {
    desc = "Delete all buffers except active ones"
})

local function toggle_spelling()
    vim.opt.spell = not vim.opt.spell:get()
end

vim.api.nvim_create_user_command('Spell', toggle_spelling, {
    desc = "Toggle spelling"
})
