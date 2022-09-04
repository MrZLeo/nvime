local chadtree_settings = {
    ["theme.text_colour_set"] = "solarized_universal",
    ["theme.icon_glyph_set"] = "ascii"
}
vim.api.nvim_set_var("chadtree_settings", chadtree_settings)

-- open chadtree when nvim a directory
vim.cmd [[
    augroup open_dir_by_chadtree
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') | execute 'CHADopen' | execute 'cd '.argv()[0] | endif
    augroup end
]]
