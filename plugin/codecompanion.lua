vim.pack.add({
    {
        src = "https://github.com/olimorris/codecompanion.nvim",
        version = vim.version.range('*')
    }
})

-- Integration with fidget.nvim for CodeCompanion requests
local progress = require("fidget.progress")

local M = {}

function M:init()
    local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequestStarted",
        group = group,
        callback = function(request)
            local handle = M:create_progress_handle(request)
            M:store_progress_handle(request.data.id, handle)
        end,
    })

    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequestFinished",
        group = group,
        callback = function(request)
            local handle = M:pop_progress_handle(request.data.id)
            if handle then
                M:report_exit_status(handle, request)
                handle:finish()
            end
        end,
    })
end

M.handles = {}

function M:store_progress_handle(id, handle)
    M.handles[id] = handle
end

function M:pop_progress_handle(id)
    local handle = M.handles[id]
    M.handles[id] = nil
    return handle
end

function M:create_progress_handle(request)
    return progress.handle.create({
        title = " Requesting assistance (" .. request.data.interaction .. ")",
        message = "In progress...",
        lsp_client = {
            name = M:llm_role_title(request.data.adapter),
        },
    })
end

function M:llm_role_title(adapter)
    local parts = {}
    table.insert(parts, adapter.formatted_name)
    if adapter.model and adapter.model ~= "" then
        table.insert(parts, "(" .. adapter.model .. ")")
    end
    return table.concat(parts, " ")
end

function M:report_exit_status(handle, request)
    if request.data.status == "success" then
        handle.message = "Completed"
    elseif request.data.status == "error" then
        handle.message = " Error"
    else
        handle.message = "󰜺 Cancelled"
    end
end

M:init()

require("codecompanion").setup({
    adapters = {
        http = {
            ipads = function()
                return require("codecompanion.adapters").extend("openai_compatible", {
                    env = {
                        url = "http://ipads.chat.gpt:3006",
                        api_key = "cmd:security find-generic-password -a \"$USER\" -s \"ipads_api_key\" -w",
                        chat_url = "/v1/chat/completions",
                    },
                    schema = {
                        model = {
                            default = "google/gemini-3.1-pro-preview",
                        }
                    },
                })
            end,
        },
    },
    strategies = {
        chat = {
            adapter = "opencode",
        },
        inline = {
            adapter = "ipads",
        },
    },

})
