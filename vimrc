
""""""""""""""""""""""""""""""""""""""
"Vundle-Plugin-manager
    set nocompatible              " be iMproved, required
    filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/some/path/here')

    " let Vundle manage Vundle, required
    Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}

"********************************************
"My Plugin

    " Auto complete
    Plugin 'Valloric/YouCompleteMe.git' 

    " lean & mean status/tabline for vim that's light as air  
    Plugin 'bling/vim-airline.git'

    " insert mode auto-completion for quotes, parens, brackets, etc.
    Plugin 'Raimondi/delimitMate.git'

    " Syntax checking hacks for vim 
    Plugin 'scrooloose/syntastic'

    " The ultimate snippet solution for Vim
    Plugin 'SirVer/ultisnips'
    Plugin 'honza/vim-snippets'

    " extended % matching for HTML, LaTeX, and many other languages
    Plugin 'edsono/vim-matchit'

    " Support web develop
    " Plugin 'mattn/emmet-vim.git'

    " Fuzzy file, buffer, mru, tag, etc finder
    Plugin 'kien/ctrlp.vim'

    " a Git wrapper so awesome
    Plugin 'tpope/vim-fugitive'

    " displays tags in a window, ordered by scope
    Plugin 'majutsushi/tagbar'

    " Markdown support
    Plugin 'godlygeek/tabular'
    Plugin 'plasticboy/vim-markdown'

    "intensely orgasmic commenting  
    Plugin 'scrooloose/nerdcommenter'

    " visualize your Vim undo tree
    Plugin 'sjl/gundo.vim'

    "quoting/parenthesizing made simple use cs/ds
    Plugin 'tpope/vim-surround'

    "automatically adjusts 'shiftwidth' and 'expandtab' heuristically based on the current file
    Plugin 'tpope/vim-sleuth'

    "Open URI with your favorite browser from your most favorite editor 
    Plugin 'tyru/open-browser.vim'

    "Alternate Files quickly (.c --> .h etc)
    Plugin 'vim-script/a.vim'

    "********************************************
    " Color schemes
    Plugin 'tomasr/molokai'
    Plugin 'flazz/vim-colorschemes'
"********************************************

" All of your Plugins must be added before the following line
    call vundle#end()            " required
    filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""
"--------Plugin setting start------------

"***************
"--Youcompleteme configure--
    "Recompile and diagnostics withe F5
    nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
    let g:ycm_use_ultisnips_completer = 1

"***************
"--vim-airline configure--
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#left_sep = ' '
    let g:airline#extensions#tabline#left_alt_sep = '|'
    let g:airline_powerline_fonts = 1
    set t_Co=256

"***************
"--Syntastic configure--
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    "let g:syntastic_python_python_exec = '/path/to/python3'
    " support html5
    "let g:syntastic_html_tidy_exec = 'tidy5'

"***************
"--UltiSnips configure--
    " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<c-b>"
    let g:UltiSnipsJumpBackwardTrigger="<c-z>"
    " If you want :UltiSnipsEdit to split your window.
    let g:UltiSnipsEditSplit="vertical"

"***************
"--matchit configure--
    let b:match_words='\<begin\>:\<end\>' 
    let b:match_ignorecase = 1

"***************
"--emmet configure--
    "let g:user_emmet_mode='n'    "only enable normal mode functions.
    "let g:user_emmet_mode='inv'  "enable all functions, which is equal to
    "let g:user_emmet_mode='a'    "enable all function in all mode.
    "Enable just for html/css
    "let g:user_emmet_install_global = 0
    "autocmd FileType html,css EmmetInstall

"***************
"--ctrlp configure--
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlP'

"***************
"--tagbar configure--
    nmap <F3> :TagbarToggle<CR>

"***************
"--vim-markdown configure--
    let g:vim_markdown_folding_disabled=1


"***************
"--gundo configure--
    nnoremap <F4> :GundoToggle<CR>
    let g:gundo_width = 60
    let g:gundo_preview_height = 40
    let g:gundo_right = 1

"***************
"--open-browser configure--
    nmap gx <Plug>(openbrowser-smart-search)
    vmap gx <Plug>(openbrowser-smart-search)
    " Open URI under cursor.
    nmap ob <Plug>(openbrowser-open)
    " Open selected URI.
    vmap ob <Plug>(openbrowser-open)
    " Search word under cursor.
    nmap ob <Plug>(openbrowser-search)
    " Search selected word. 
    vmap ob <Plug>(openbrowser-search)
    " If it looks like URI, Open URI under cursor.
    " Otherwise, Search word under cursor.
    nmap ob <Plug>(openbrowser-smart-search)
    " If it looks like URI, Open selected URI.
    " Otherwise, Search selected word.
    vmap ob <Plug>(openbrowser-smart-search)
    " In command-line
    " :OpenBrowser http://google.com/
    " :OpenBrowserSearch ggrks
    " :OpenBrowserSmartSearch http://google.com/
    " :OpenBrowserSmartSearch ggrks


"***************
"***************
"***************
"***************
"***************
"--------Plugin setting end------------

"***************
"vim comfigure

"--Other vim setting--
    "set ignorecase        " 搜索模式里忽略大小写
    "set smartcase        " 如果搜索模式包含大写字符，不使用 'ignorecase' 选项。只有在输入搜索模式并且打开 'ignorecase' 选项时才会使用。
    set autowrite        " 自动把内容写回文件: 如果文件被修改过，在每个 :next、:rewind、:last、:first、:previous、:stop、:suspend、:tag、:!、:make、CTRL-] 和 CTRL-^命令时进行；用 :buffer、CTRL-O、CTRL-I、'{A-Z0-9} 或 `{A-Z0-9} 命令转到别的文件时亦然。
    set autoindent        " 设置自动对齐(缩进)：即每行的缩进值与上一行相等；使用 noautoindent 取消设置
    "set smartindent        " 智能对齐方式
    set tabstop=4        " 设置制表符(tab键)的宽度
    set softtabstop=4     " 设置软制表符的宽度    
    set shiftwidth=4    " (自动) 缩进使用的4个空格
    set cindent            " 使用 C/C++ 语言的自动缩进方式
    set cinoptions={0,1s,t0,n-2,p2s,(03s,=.5s,>1s,=1s,:1s     "设置C/C++语言的具体缩进方式
    "set backspace=2    " 设置退格键可用
    set showmatch        " 设置匹配模式，显示匹配的括号
    set linebreak        " 整词换行
    set whichwrap=b,s,<,>,[,] " 光标从行首和行末时可以跳到另一行去
    "set hidden " Hide buffers when they are abandoned
    set mouse=a            " Enable mouse usage (all modes)    "使用鼠标
    set number            " Enable line number    "显示行号
    "set previewwindow    " 标识预览窗口
    set history=50        " set command history to 50    "历史记录50条

"--状态行设置--
    set laststatus=2 " 总显示最后一个窗口的状态行；设为1则窗口数多于一个的时候显示最后一个窗口的状态行；0不显示最后一个窗口的状态行
    set ruler            " 标尺，用于显示光标位置的行号和列号，逗号分隔。每个窗口都有自己的标尺。如果窗口有状态行，标尺在那里显示。否则，它显示在屏幕的最后一行上。

"--命令行设置--
    set showcmd            " 命令行显示输入的命令
    set showmode        " 命令行显示vim当前模式

"--find setting--
    set incsearch        " 输入字符串就显示匹配点
    set hlsearch      

"--fold setting--
    set foldmethod=syntax " 用语法高亮来定义折叠
    set foldlevel=100 " 启动vim时不要自动折叠代码
    set foldcolumn=5 " 设置折叠栏宽度

"--Color scheme--
    colorscheme desert " elflord ron peachpuff default 设置配色方案，vim自带的配色方案保存在/usr/share/vim/vim72/colors目录下

"-- QuickFix setting --
    " 按下F6，执行make clean
    map <F6> :make clean<CR><CR><CR>
    " 按下F7，执行make编译程序，并打开quickfix窗口，显示编译信息
    map <F7> :make<CR><CR><CR> :copen<CR><CR>
    " 按下F8，光标移到上一个错误所在的行
    map <F8> :cp<CR>
    " 按下F9，光标移到下一个错误所在的行
     map <F9> :cn<CR>
    " 以下的映射是使上面的快捷键在插入模式下也能用
    imap <F6> <ESC>:make clean<CR><CR><CR>
    imap <F7> <ESC>:make<CR><CR><CR> :copen<CR><CR>
    imap <F8> <ESC>:cp<CR>
    imap <F9> <ESC>:cn<CR>

"-- For ruby development setting --
    " install rsense 
    "let g:rsenseHome = "/home/blueyi/opt/rsense-0.3"
    "If you want to start completion automatically, add the following code to .vimrc and restart Vim.
    "let g:rsenseUseOmniFunc = 1

    " F9 run ruby
    "map <F9> :!ruby -w % <CR>
    "imap <F9> <ESC>:!ruby -w % <CR>
    " F8 check ruby syntax only
    "map <F8> :w !ruby -c % <CR>
    "imap <F8> <ESC>:w !ruby -c % <CR>

    "autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1 
    "autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
    "autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

"-- For python development setting --


"-- Chinese encoding support --
    set fileencodings=ucs-bom,utf-8,cp936,gb2312,gb18030,big5,euc-jp,euc-kr,latin1
    set termencoding=utf-8
    set encoding=utf-8 


