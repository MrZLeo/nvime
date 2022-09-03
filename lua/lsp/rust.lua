-- local nvim_lsp = require 'lspconfig'
-- local rt = require 'rust-tools'

local opts = {
    tools = { -- rust-tools options
        autoSetHints = true,
        reload_workspace_from_cargo_toml = true,
        executor = require("rust-tools/executors").termopen,
        runnables = {
            use_telescope = true
        },
        inlay_hints = {
            -- automatically set inlay hints (type hints)
            -- default: true
            auto = true,

            -- Only show inlay hints for the current line
            only_current_line = false,

            -- whether to show parameter hints with the inlay hints or not
            -- default: true
            show_parameter_hints = true,

            -- prefix for parameter hints
            -- default: "<-"
            parameter_hints_prefix = "<- ",

            -- prefix for all the other hints (type, chaining)
            -- default: "=>"
            other_hints_prefix = "=> ",

            -- whether to align to the length of the longest line in the file
            max_len_align = false,

            -- padding from the left if max_len_align is true
            max_len_align_padding = 1,

            -- whether to align to the extreme right or not
            right_align = false,

            -- padding from the right if right_align is true
            right_align_padding = 7,

            -- The color of the hints
            highlight = "Comment",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
        -- on_attach is a callback called when the language server attachs to the buffer
        standalone = true,
        -- on_attach = function(_, bufnr)
        --     -- Hover actions
        --     vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
        --     -- Code action groups
        --     vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
        -- end,
        on_attach = require('lsp.settings').on_attach,
        settings = {
            ["rust-analyzer"] = {
                server = {
                    path = "/opt/homebrew/bin/rust-analyzer"
                },
                checkOnSave = {
                    command = "clippy",
                    allTargets = false
                },
                procMacro = {
                    enable = true
                },
            }
        },
    },
}

vim.cmd [[ autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false }) ]]
vim.keymap.set('n', '<Space>r', ':RustRunnables<CR>');

require('rust-tools').setup(opts)
