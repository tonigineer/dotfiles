" ~/.vimrc -- vim configuration

" ——— General ——————————————————————————————————————————————————————————————————

syntax on
filetype plugin indent on

set encoding=utf-8
set nobackup
set noswapfile
set clipboard=unnamedplus

" ——— UI ———————————————————————————————————————————————————————————————————————

set number
set showmatch
set hlsearch
set incsearch
set ignorecase
set smartcase

" Cursor shape: block in NORMAL, thin line in INSERT.
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" ——— Indentation ——————————————————————————————————————————————————————————————

set autoindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=80


" ——— Key Mappings —————————————————————————————————————————————————————————————

" Quick escape from INSERT mode.
inoremap <silent> kj <esc>
inoremap <silent> jk <esc>

" Save with Ctrl-S in any mode.
nnoremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

" Familiar undo / redo bindings.
inoremap <C-Z> <esc> u i
inoremap <C-Y> <esc> <C-R> i
nnoremap <C-Z> u
nnoremap <C-Y> <C-R>

" Move current line up/down in NORMAL mode.
nnoremap <S-j> :m .+1<CR>==
nnoremap <S-k> :m .-2<CR>==

" Move selected block up/down in VISUAL mode.
xnoremap <S-j> :m '>+1<CR>gv=gv
xnoremap <S-k> :m '<-2<CR>gv=gv

" Single-press indent/dedent (replaces motion-based > <).
nnoremap > >>
nnoremap < <<
vnoremap > >gv
vnoremap < <gv

