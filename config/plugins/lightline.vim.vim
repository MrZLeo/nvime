if &laststatus < 2
    " 窗口一直有状态行
    set laststatus=2
endif


function! s:lightline_is_lean() abort
    return &filetype =~? '\v^defx|mundo(diff)?$'
endfunction

function! s:lightline_is_plain() abort
    return &buftype ==? 'terminal' || &filetype =~? '\v^help|coc-explorer|denite|defx|vista_kind|vista|tagbar$'
endfunction

function! LightlineLineinfo() abort
    return &filetype ==? 'help'             ? ''  :
    \      &filetype ==? 'defx'             ? ' ' :
    \      &filetype ==? 'coc-explorer'     ? ' ' :
    \      &filetype ==? 'denite'           ? ' ' :
    \      &filetype ==? 'tagbar'           ? ' ' :
    \      &filetype ==? 'vista_kind'       ? ' ' :
    \      &filetype ==? 'vista'            ? ' ' :
    \      &filetype =~? '\v^mundo(diff)?$' ? ' ' :
    \      s:lightline_is_lean() || s:lightline_is_plain() ? ' '  :
    \      printf(' %3ld%% ☰ %3ld:%2ld', 100*line('.')/line('$'),  line('.'), col('.'))
endfunction

function! LightLineGitInfo()abort
    if &filetype ==? 'defx' || &filetype ==? 'vista'
        return ""
    endif
    let gitbranch=get(g:, 'coc_git_status', '')
    let gitcount=get(b:, 'coc_git_status', '')
    let gitinfo = []
    if empty(gitbranch)
        let gitbranch=""
    endif
    if empty(gitcount)
        let gitcount=""
    endif
    call add(gitinfo,gitbranch)
    call add(gitinfo,gitcount)
    return trim(join(gitinfo,''))
endfunction

let g:lightline = {
    \ 'colorscheme': 'edge',
    \ 'enable': {
    \ 'tabline': 0
    \},
    \ 'active': {
    \   'left': [ [ 'mode', 'paste', 'gitinfo' ],
    \             [ 'readonly', 'filename', 'modified'],
    \             [ 'method', 'cocstatus']
    \           ],
    \   'right': [
    \       ['cocerror'], ['cocwarn'], ['cocfix'],
    \       [ 'filetype', 'fileencoding', 'fileformat', 'lineinfo'],
    \       [ 'percent' ]
    \   ]
    \ },
    \ 'component_function': {
    \   'cocstatus': 'coc#status',
    \   'lineinfo': 'LightlineLineinfo',
    \   'readonly': 'common#functions#ReadOnly',
    \   'gitinfo': 'LightLineGitInfo',
    \   'gitbranch': 'FugitiveHead',
    \   'cocerror': 'common#functions#CocError',
    \   'cocwarn' : 'common#functions#CocWarn',
    \   'cocfix': 'common#functions#CocFix',
    \   'percent': 'ScrollStatus'
    \ },
\ }
