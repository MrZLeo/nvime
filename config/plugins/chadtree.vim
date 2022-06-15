" config theme
let g:chadtree_settings = {
      \ "theme.text_colour_set": "solarized_universal",
      \ "theme.icon_glyph_set": "ascii"
      \ }

" open chadtree when nvim a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'CHADopen' | execute 'cd '.argv()[0] | endif

