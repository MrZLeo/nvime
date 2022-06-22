" enable true color
set termguicolors

" 美化相关基本配置
" 高亮当前行列
set cursorline
set colorcolumn=80

" 光标
set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20

" 搜索高亮
set incsearch

" 高亮匹配内容
set hlsearch
set list
set listchars=tab:\|\→·,nbsp:⣿,extends:»,precedes:«
set listchars+=eol:¬
set listchars+=trail:·

" 搜索高亮颜色
hi Search ctermfg=17 ctermbg=190 guifg=#000000 guibg=#ffff00

" 设置弹出框大小, 0 则有多少显示多少
set pumheight=20
set pumblend=20 " 提示框透明

" 主题选择
let g:one_allow_italics = 1
silent! colorscheme edge
