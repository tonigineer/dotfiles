syntax on
filetype on

set noswapfile
set number
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set textwidth=80
set nobackup
set hlsearch
set showmatch

inoremap <silent> kj <esc>
inoremap <silent> jk <esc>

noremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

nnoremap <C-Z> u
nnoremap <C-Y> <C-R>

