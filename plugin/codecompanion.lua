vim.pack.add({
    {
        src = "https://github.com/olimorris/codecompanion.nvim",
        version = vim.version.range('*')
    }
})

require("codecompanion_progress").init()

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
