local ensure_installed = {
    "bash", "bibtex", "c", "cmake", "comment", "cpp", "diff", "dockerfile",
    "fish", "git_rebase", "gitattributes", "go", "gomod", "gowork", "haskell",
    "json", "json5", "latex", "llvm", "lua", "make", "markdown",
    "markdown_inline", "ninja", "perl", "proto", "python", "rst", "rust",
    "sql", "toml", "vim", "yaml", "kdl", "gn", "typescript"
}

-- enable settings
local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
    return
end

local function setup_macos_treesitter_build_env()
    if vim.fn.has("macunix") ~= 1 then
        return
    end

    if vim.fn.executable("xcrun") == 1 then
        local sdkroot = vim.trim(vim.fn.system({ "xcrun", "--sdk", "macosx", "--show-sdk-path" }))
        if vim.v.shell_error == 0 and sdkroot ~= "" and vim.fn.isdirectory(sdkroot) == 1 then
            vim.env.SDKROOT = sdkroot
        end
    end

    -- Keep parser builds on Apple clang to avoid missing libc headers.
    if vim.fn.executable("/usr/bin/clang") == 1 then
        vim.env.CC = "/usr/bin/clang"
    end
    if vim.fn.executable("/usr/bin/clang++") == 1 then
        vim.env.CXX = "/usr/bin/clang++"
    end
end

setup_macos_treesitter_build_env()

treesitter.install(ensure_installed):wait(3000)
treesitter.update(ensure_installed)

vim.api.nvim_create_autocmd('FileType', {
    pattern = { '<filetype>' },
    callback = function() vim.treesitter.start() end,
})
