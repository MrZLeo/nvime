-- key map
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap(
    "n",
    "<leader>f",
    "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>",
    opts)
keymap("n", "<Space>t", "<cmd>Telescope live_grep<cr>", opts)
