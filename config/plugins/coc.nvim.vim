" coc插件列表，可根据需要进行删减
let g:coc_global_extensions = [
    \ 'coc-vimlsp',
    \ 'coc-sh',
    \ 'coc-clangd',
    \ 'coc-lists',
    \ 'coc-word',
    \ 'coc-ci',
    \ 'coc-zi',
    \ 'coc-marketplace',
    \ 'coc-rust-analyzer',
    \ 'coc-json',
    \ 'coc-lua',
    \ 'coc-snippets'
  \ ]

" coc插件安装目录
let g:coc_data_home = g:cache_root_path . 'coc/'

" coc-settings.json所在目录
let g:coc_config_home = g:other_config_root_path

" 卸载不在列表中的插件
function! s:uninstall_unused_coc_extensions() abort
    if has_key(g:, 'coc_global_extensions')
        for e in keys(json_decode(join(readfile(expand(g:coc_data_home . '/extensions/package.json')), "\n"))['dependencies'])
            if index(g:coc_global_extensions, e) < 0
                execute 'CocUninstall ' . e
            endif
        endfor
    endif
endfunction

autocmd User CocNvimInit call s:uninstall_unused_coc_extensions()

" 检查当前光标前面是不是空白字符
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" tab触发补全或者选择下一个补全
inoremap <silent><expr> <TAB>
	\ coc#pum#visible() ? coc#pum#next(1):
	\ <SID>check_back_space() ? "\<Tab>" :
	\ coc#refresh()

" shift tab 选择上一个补全
inoremap <silent><expr> <S-TAB>
    \ coc#pum#visible() ? coc#pum#prev(1) :
    \ "\<C-h>"

" down 选择下一个补全
inoremap <silent><expr> <down>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ "\<down>"

" up 选择上一个补全
inoremap <silent><expr> <up>
    \ coc#pum#visible() ? coc#pum#prev(1) :
    \ "\<up>"

" alt w b 用于补全块的跳转，优先补全块跳转
let g:coc_snippet_next = '<c-w>'
let g:coc_snippet_prev = '<c-b>'

" 回车选中或者扩展选中的补全内容
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#comfirm() : "\<CR>"

" 跳转到定义
nmap <silent> gd <Plug>(coc-definition)
" 跳转到类型定义
nmap <silent> gy <plug>(coc-type-definition)
" 跳转到实现
nmap <silent> gi <plug>(coc-implementation)
" 跳转到引用
nmap <silent> gr <plug>(coc-references)
" 重构refactor,需要lsp支持
nmap <silent> <space>rf <Plug>(coc-refactor)
" 修复代码
nmap <silent> <space>f  <Plug>(coc-fix-current)
" 变量重命名
nmap <silent> <space>rn <Plug>(coc-rename)

" 使用K悬浮显示定义
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

" 函数文档
nnoremap <silent> K :call <SID>show_documentation()<CR>

nnoremap <silent> <space>A  :<C-u>CocFzfList diagnostics<CR>
nnoremap <silent> <space>a  :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> <space>c  :<C-u>CocFzfList commands<CR>
nnoremap <silent> <space>l  :<C-u>CocFzfList<CR>
nnoremap <silent> <space>o  :<C-u>CocFzfList outline<CR>
nnoremap <silent> <space>O  :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <space>s  :<C-u>CocFzfList services<CR>
nnoremap <silent> <space>p  :<C-u>CocFzfListResume<CR>

" CocAction
nnoremap <silent> <space>ac <Plug>(coc-codeaction-cursor)<CR>

"""""""""""""""""""""""
" coc-plug config
" 下面是coc插件的配置
"""""""""""""""""""""""

function! s:lc_coc_lists() abort
    call coc#config('list.maxHeight', 10)
    call coc#config('list.maxPreviewHeight', 8)
    call coc#config('list.autoResize', v:false)
    call coc#config('list.source.grep.command', 'rg')
    call coc#config('list.source.grep.defaultArgs', [
                \ '--column',
                \ '--line-number',
                \ '--no-heading',
                \ '--color=always',
                \ '--smart-case'
            \ ])
    call coc#config('list.source.lines.defaultArgs', ['-e'])
    call coc#config('list.source.words.defaultArgs', ['-e'])
    call coc#config('list.source.files.command', 'rg')
    call coc#config('list.source.files.args', ['--files'])
    call coc#config('list.source.files.excludePatterns', ['.git'])
endfunction

function! s:lc_coc_clangd() abort
    call coc#config('clangd.semanticHighlighting', v:true)
endfunction

function! s:lc_coc_vimlsp() abort
    let g:markdown_fenced_languages = [
        \ 'vim',
        \ 'help'
    \ ]
endfunction

function! s:lc_coc_ci() abort
    nmap <silent> w <Plug>(coc-ci-w)
    nmap <silent> b <Plug>(coc-ci-b)
endfunction

function! s:lc_coc_rainbow_fart() abort
    call coc#config("rainbow-fart.ffplay", "ffplay")
endfunction

" 遍历coc插件列表，载入插件配置
let s:coc_config_functions = {
            \ 'coc-lists': function('<SID>lc_coc_lists'),
            \ 'coc-clangd': function('<SID>lc_coc_clangd'),
            \ 'coc-ci': function('<SID>lc_coc_ci'),
            \ 'coc-vimlsp': function('<SID>lc_coc_vimlsp'),
            \ }

