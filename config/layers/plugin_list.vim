" 数据库
Plug 'tpope/vim-dadbod' | Plug 'kristijanhusak/vim-dadbod-ui' | Plug 'kristijanhusak/vim-dadbod-completion'

" 主题theme类插件
Plug 'sainnhe/edge'

" 顶栏和底栏
Plug 'itchyny/lightline.vim'

" 彩虹括号
Plug 'p00f/nvim-ts-rainbow'

" 快速包围
Plug 'tpope/vim-surround'

" 显示清除尾部空格
Plug 'ntpeters/vim-better-whitespace'

" 对齐
Plug 'junegunn/vim-easy-align', {'on': ['EasyAlign', '<Plug>(EasyAlign)']}

" 缩进线
Plug 'glepnir/indent-guides.nvim'

" 多光标
Plug 'mg979/vim-visual-multi'

" 悬浮终端
Plug 'voldikss/vim-floaterm', {'on': ['FloatermNew', 'FloatermToggle']}

" 起始界面
Plug 'mhinz/vim-startify'

" 翻译插件
Plug 'iamcco/dict.vim', {'on':
    \ [
    \ '<Plug>DictSearch', '<Plug>DictVSearch', '<Plug>DictWSearch',
    \ '<Plug>DictWVSearch', '<Plug>DictRSearch', '<Plug>DictRVSearch'
    \ ]}
" 搜索显示数量
Plug 'kevinhwang91/nvim-hlslens'


" vim中文文档
Plug 'yianwillis/vimcdoc'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-treesitter/nvim-treesitter-refactor'
Plug 'romgrk/nvim-treesitter-context'

" 总是匹配tag
Plug 'valloric/MatchTagAlways', {'for': ['html', 'css', 'xml']}

" 显示颜色 例如: #654456
Plug 'norcalli/nvim-colorizer.lua'

" 查看启动时间
Plug 'dstein64/vim-startuptime', {'on':'StartupTime'}

" 语法检查
Plug 'rhysd/vim-grammarous', {'for': ['markdown', 'vimwiki', 'md', 'tex']}
" 首先需要在config/plugin_list.vim中增加插件
Plug 'matze/vim-move', {'on': [
            \ '<Plug>MoveBlockDown',
            \ '<Plug>MoveBlockUp',
            \ '<Plug>MoveBlockRight',
            \ '<Plug>MoveBlockLeft']}
if has("nvim")
    Plug 'simnalamburt/vim-mundo'
endif
if has('nvim')
    Plug 'kyazdani42/nvim-web-devicons'
else
    Plug 'ryanoasis/vim-devicons'
endif

if has('nvim')
    Plug 'dstein64/nvim-scrollview'
endif
Plug 'ernstwi/vim-secret'
Plug 'ZSaberLv0/ZFVimDirDiff'

" fondler
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}

" gtags 管理
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/vim-preview'

" Rust
Plug 'rust-lang/rust.vim'

" comment
Plug 'tpope/vim-commentary'

" icon
Plug 'ryanoasis/vim-devicons'

" pair bracket
Plug 'jiangmiao/auto-pairs'

" 快速移动
 Plug 'easymotion/vim-easymotion', {'on':
    \ [
    \ '<Plug>(easymotion-bd-f)', '<Plug>(easymotion-overwin-f)',
    \ '<Plug>(easymotion-overwin-f2)', '<Plug>(easymotion-bd-jk)',
    \ '<Plug>(easymotion-overwin-line)', '<Plug>(easymotion-bd-w)',
    \ '<Plug>(easymotion-overwin-w)', '<Plug>(easymotion-s)',
    \ ]}
