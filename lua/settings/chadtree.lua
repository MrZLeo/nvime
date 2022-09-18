local chadtree_settings = {
    ["theme.text_colour_set"] = "solarized_universal",
    ["theme.icon_glyph_set"] = "ascii"
}
vim.api.nvim_set_var("chadtree_settings", chadtree_settings)

-- open chadtree when nvim a directory
local chadtree = vim.api.nvim_create_augroup("open_dir_by_chadtree", { clear = true })
vim.api.nvim_create_autocmd(
    { "StdinReadPre" },
    {
        command = "let s:std_in=1",
        group = chadtree
    }
)
vim.api.nvim_create_autocmd(
    { "VimEnter" },
    {
        command = "if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') | execute 'CHADopen' | execute 'cd '.argv()[0] | endif",
        group = chadtree
    }
)
