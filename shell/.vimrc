syntax on                   " syntax highlighting
filetype plugin on          " enable filetype detection
filetype plugin indent on   "allow auto-indenting depending on file type

set nocompatible        " disable compatibility to old-time vi
set nobackup            " don't make backup files
set autoread            " automatically read files when opened
set matchtime=1         " match the whole line
set report=0            " don't show error messages
set fencs=utf-8,gbk     " set the default encoding
set termencoding=utf-8  " set the terminal encoding
set encoding=utf-8      " set the file encoding

set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set ttyfast                 " speed up scrolling in Vim
set ignorecase              " ignore case

" display
set number          " show absolute line numbers
set showcmd         " show command in status line
set ruler           " show line numbers in the bottom
set cursorline      " highlight current line
set showmatch       " highlight matching brackets
set hlsearch        " highlight search
set incsearch       " incremental search

if has("termguicolors") && has("nvim") " set true colors on NeoVim
    set termguicolors
endif

set autoindent      " indent a new line the same amount as the line just typed
set expandtab       " converts tabs to white space
set tabstop=4       " number of columns occupied by a tab
set softtabstop=4   " see multiple spaces as tabstops so <BS> does the right thing
set shiftwidth=4    " width for autoindents

set foldmethod=indent   " fold by indentation
set foldlevelstart=99   " start folding at 99
set laststatus=2        " show status bar

" install vim-plug
" unix
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

" windows
" iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni $HOME/vimfiles/autoload/plug.vim -Force

" vim-plug path
call plug#begin('~/.vim/plugged')

" themes
Plug 'crusoexia/vim-monokai'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" components
Plug 'nanotee/zoxide.vim'
Plug 'sbdchd/neoformat'

" completions
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" shortcut
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

" language
Plug 'kaarmu/typst.vim'
Plug 'yaegassy/coc-ruff', {'do': 'yarn install --frozen-lockfile'}

call plug#end()

colorscheme monokai

" coc.nvim
let g:coc_global_extensions = [
    \ 'coc-emmet',
    \ 'coc-explorer',
    \ 'coc-git',
    \ 'coc-gitignore',
    \ 'coc-highlight',
    \ 'coc-json',
    \ 'coc-lists',
    \ 'coc-markdownlint',
    \ 'coc-marketplace',
    \ 'coc-pairs',
    \ 'coc-prettier',
    \ 'coc-rust-analyzer',
    \ 'coc-texlab',
    \ 'coc-yaml']

" airline
" let g:airline_theme = 'silver'
let g:airline_powerline_fonts = 0
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#wordcount#enabled = 1
let g:airline#extensions#keymap#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffer_idx_format = {
       \ '0': '0 ',
       \ '1': '1 ',
       \ '2': '2 ',
       \ '3': '3 ',
       \ '4': '4 ',
       \ '5': '5 ',
       \ '6': '6 ',
       \ '7': '7 ',
       \ '8': '8 ',
       \ '9': '9 '
       \}

let g:airline_section_warning = ''
let g:airline_section_c = ''
let g:airline_section_x = ''
let g:airline_section_z = airline#section#create_right(['%l', '%c'])

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
" let g:airline_left_sep = '»'
" let g:airline_right_sep = '«'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.spell = '⁇'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" keymaps
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>, <Plug>AirlineSelectPrevTab
nmap <leader>. <Plug>AirlineSelectNextTab
nmap <leader>q :bp<cr>:bd #<cr>
nmap <space>e <Cmd>CocCommand explorer<CR>
