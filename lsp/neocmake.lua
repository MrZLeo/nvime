---@type vim.lsp.Config
return {
    cmd = { 'neocmakelsp', '--stdio' },
    filetypes = { 'cmake' },
    single_file_support = true,
}
