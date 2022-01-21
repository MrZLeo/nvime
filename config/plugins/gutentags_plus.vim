let g:gutentags_plus_switch = 1
let g:gutentags_plus_nomap = 1

noremap <silent> <leader>js :GscopeFind s <C-R><C-W><cr>
noremap <silent> <leader>jn :GscopeFind g <C-R><C-W><cr>
noremap <silent> <leader>jc :GscopeFind c <C-R><C-W><cr>
noremap <silent> <leader>jt :GscopeFind t <C-R><C-W><cr>
noremap <silent> <leader>je :GscopeFind e <C-R><C-W><cr>
noremap <silent> <leader>jf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>ji :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>jd :GscopeFind d <C-R><C-W><cr>
noremap <silent> <leader>ja :GscopeFind a <C-R><C-W><cr>
noremap <silent> <leader>jz :GscopeFind z <C-R><C-W><cr>
