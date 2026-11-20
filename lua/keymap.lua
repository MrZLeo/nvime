-- Keymap: lua version

-- windows
vim.keymap.set("n", "<c-h>", "<C-w>h")
vim.keymap.set("n", "<c-j>", "<C-w>j")
vim.keymap.set("n", "<c-k>", "<C-w>k")
vim.keymap.set("n", "<c-l>", "<C-w>l")
vim.keymap.set("t", "<c-h>", "<c-\\><c-n><c-w>h")
vim.keymap.set("t", "<c-j>", "<c-\\><c-n><c-w>j")
vim.keymap.set("t", "<c-k>", "<c-\\><c-n><c-w>k")
vim.keymap.set("t", "<c-l>", "<c-\\><c-n><c-w>l")

-- split windows
vim.keymap.set("n", "<c-w>k", ":abo split <cr>")
vim.keymap.set("n", "<c-w>h", ":abo vsplit <cr>")
vim.keymap.set("n", "<c-w>j", ":rightbelow split <cr>")
vim.keymap.set("n", "<c-w>l", ":rightbelow vsplit <cr>")

-- close windows
-- vim.keymap.set('n', 'q', '<esc>:close<cr>', { silent = true })
-- vim.keymap.set('v', 'q', '<esc>:close<cr>', { silent = true })

-- no hightlight
vim.keymap.set("n", "<BackSpace>", ":nohl<cr>")

-- use Q as macro trigger rather than q
-- vim.keymap.set('n', 'Q', 'q')

-- use double space to save file
vim.keymap.set("n", "<space><space>", "<esc>:w<CR>", { silent = true })

-- Copy through OSC52 to the local clipboard and paste from the internal
-- unnamed register inside Neovim. Use the terminal's paste shortcut for
-- external clipboard content.
local osc52 = require("vim.ui.clipboard.osc52")

local function paste()
    return {
        vim.fn.split(vim.fn.getreg(""), "\n"),
        vim.fn.getregtype(""),
    }
end

vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
    },
    paste = {
        ["+"] = paste,
        ["*"] = paste,
    },
}

-- Oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>")

-- Outline
vim.keymap.set("n", "<Space>o", "<CMD>Outline<CR>", { desc = "Toggle outline" })
