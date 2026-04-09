vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local ensure_installed = {
    "bash", "bibtex", "c", "cmake", "comment", "cpp", "diff", "dockerfile",
    "fish", "git_rebase", "gitattributes", "go", "gomod", "gowork", "haskell",
    "json", "json5", "latex", "llvm", "lua", "make", "markdown",
    "markdown_inline", "ninja", "perl", "proto", "python", "rst", "rust",
    "sql", "toml", "vim", "yaml", "kdl", "gn", "typescript"
}

local treesitter = require("nvim-treesitter")
local sync_timeout_ms = 300000

vim.api.nvim_create_user_command("TSSyncParsers", function()
    vim.notify("Syncing Tree-sitter parsers...", vim.log.levels.INFO)

    local ok, result = pcall(function()
        return treesitter.update(ensure_installed, { summary = true }):wait(sync_timeout_ms)
    end)

    if ok and result then
        vim.notify("Tree-sitter parsers are up to date.", vim.log.levels.INFO)
    else
        vim.notify("Tree-sitter parser sync failed. Check :messages for details.", vim.log.levels.ERROR)
    end
end, {
    desc = "Install and update Tree-sitter parsers used by this config",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and kind == "update" then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end,
})
