" 主题theme类插件
Plug 'sainnhe/edge'
Plug 'shaunsingh/nord.nvim'

" 顶栏和底栏
Plug 'itchyny/lightline.vim'

" 彩虹括号
Plug 'p00f/nvim-ts-rainbow'

" 快速包围
Plug 'tpope/vim-surround'

" 显示清除尾部空格
Plug 'ntpeters/vim-better-whitespace'

" 缩进线
Plug 'glepnir/indent-guides.nvim'

" 多光标
Plug 'mg979/vim-visual-multi'

" 悬浮终端
Plug 'voldikss/vim-floaterm', {'on': ['FloatermNew', 'FloatermToggle']}

" 起始界面
Plug 'mhinz/vim-startify'

" 搜索显示数量
Plug 'kevinhwang91/nvim-hlslens'

" vim中文文档
Plug 'yianwillis/vimcdoc'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-treesitter/nvim-treesitter-refactor'
Plug 'romgrk/nvim-treesitter-context'

" 显示颜色 例如: #654456
Plug 'norcalli/nvim-colorizer.lua'

" 查看启动时间
Plug 'dstein64/vim-startuptime', {'on':'StartupTime'}

" 语法检查
Plug 'rhysd/vim-grammarous', {'for': ['markdown', 'vimwiki', 'md', 'tex']}

" fondler
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}

" gtags 管理
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/vim-preview'

" comment
Plug 'tpope/vim-commentary'

" pair bracket
Plug 'jiangmiao/auto-pairs'

" 搜索快速跳转
 Plug 'easymotion/vim-easymotion', {'on':
    \ [
    \ '<Plug>(easymotion-bd-f)', '<Plug>(easymotion-overwin-f)',
    \ '<Plug>(easymotion-overwin-f2)', '<Plug>(easymotion-bd-jk)',
    \ '<Plug>(easymotion-overwin-line)', '<Plug>(easymotion-bd-w)',
    \ '<Plug>(easymotion-overwin-w)', '<Plug>(easymotion-s)',
    \ ]}
