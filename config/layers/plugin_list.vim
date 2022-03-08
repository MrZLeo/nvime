" 数据库
Plug 'tpope/vim-dadbod' | Plug 'kristijanhusak/vim-dadbod-ui' | Plug 'kristijanhusak/vim-dadbod-completion'
" 全局替换插件
Plug 'brooth/far.vim'
" 主题theme类插件
Plug 'sainnhe/edge'
" 顶栏和底栏
Plug 'itchyny/lightline.vim'
" 彩虹括号
if has('nvim')
    Plug 'p00f/nvim-ts-rainbow'
else
    Plug 'luochen1990/rainbow'
endif
" 函数列表
Plug 'liuchengxu/vista.vim', {'on': ['Vista!!', 'Vista']}
" 自动补全括号
Plug 'jiangmiao/auto-pairs'
if has("nvim")
    Plug 'andymass/vim-matchup'
endif
" 快速包围
Plug 'tpope/vim-surround'
" Plug 'machakann/vim-sandwich'
" 重复上次的动作
Plug 'tpope/vim-repeat'
" 显示清除尾部空格
Plug 'ntpeters/vim-better-whitespace'
" 代码段
Plug 'honza/vim-snippets'
" Plug 'SirVer/ultisnips'
" 快速选择窗口
Plug 't9md/vim-choosewin'
" 快速移动
Plug 'easymotion/vim-easymotion', {'on':
   \ [
   \ '<Plug>(easymotion-bd-f)', '<Plug>(easymotion-overwin-f)',
   \ '<Plug>(easymotion-overwin-f2)', '<Plug>(easymotion-bd-jk)',
   \ '<Plug>(easymotion-overwin-line)', '<Plug>(easymotion-bd-w)',
   \ '<Plug>(easymotion-overwin-w)', '<Plug>(easymotion-s)',
   \ ]}
" 对齐
Plug 'junegunn/vim-easy-align', {'on': ['EasyAlign', '<Plug>(EasyAlign)']}
if has('nvim')
    " 缩进线
    Plug 'glepnir/indent-guides.nvim'
endif
" 多光标
Plug 'mg979/vim-visual-multi'
" 悬浮终端
Plug 'voldikss/vim-floaterm', {'on': ['FloatermNew', 'FloatermToggle']}
" markdown 预览插件
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug', 'vimwiki'], 'on': 'MarkdownPreview'}
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
" tmux相关插件
if  executable("tmux") && strlen($TMUX)
    " tmux与vim窗口间导航
    Plug 'christoomey/vim-tmux-navigator'
    " tmux.conf set -g focus-events on
    Plug 'tmux-plugins/vim-tmux-focus-events'
    " 在tmux和vim之间进行复制与粘贴
    " Plug 'roxma/vim-tmux-clipboard'
    " tmux补全插件
    Plug 'wellle/tmux-complete.vim'
endif
" 关闭buffer而不关闭窗口
Plug 'rbgrouleff/bclose.vim', {'on': 'Bclose'}
" latex插件
Plug 'lervag/vimtex', {'for': 'tex'}
Plug 'KeitaNakamura/tex-conceal.vim', {'for': 'tex'}
" 平滑滚动
Plug 'psliwka/vim-smoothie'
" vim中文文档
Plug 'yianwillis/vimcdoc'
if has('nvim')
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'nvim-treesitter/nvim-treesitter-refactor'
    Plug 'romgrk/nvim-treesitter-context'
else
    Plug 'sheerun/vim-polyglot'
    Plug 'octol/vim-cpp-enhanced-highlight'
endif
" 总是匹配tag
Plug 'valloric/MatchTagAlways', {'for': ['html', 'css', 'xml']}
" 显示颜色 例如: #654456
if has('nvim')
    Plug 'norcalli/nvim-colorizer.lua'
else
    Plug 'RRethy/vim-hexokinase',  { 'do': 'make hexokinase' }
endif
" 加强版的 go to file
Plug 'tpope/vim-apathy'
" 查看启动时间
Plug 'dstein64/vim-startuptime', {'on':'StartupTime'}
\ | Plug 'junegunn/limelight.vim', { 'on': 'Limelight' }
Plug 'markonm/traces.vim'
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
if has('nvim')
  Plug 'kyazdani42/nvim-tree.lua'
endif

" gtags 管理
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/vim-preview'

" Rust
Plug 'rust-lang/rust.vim'

" comment
Plug 'tpope/vim-commentary'

" debug
Plug 'puremourning/vimspector'
