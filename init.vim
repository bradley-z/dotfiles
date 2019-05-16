" ----------------------------------------------------------------------
" ---------------------------- nvim plugins ----------------------------
" ----------------------------------------------------------------------
let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

" nvim plugins (to install open nvim and run :PlugInstall)
call plug#begin('~/.config/nvim/plugged')
" allows for viewing file trees inside of neovim
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" ctrlp for fuzzy file searching
Plug 'ctrlpvim/ctrlp.vim'
" mimic sublime multiple cursors
Plug 'terryma/vim-multiple-cursors'
" gitgutter plugin for vim
Plug 'airblade/vim-gitgutter'
" status bar
Plug 'vim-airline/vim-airline'
" theme
Plug 'morhetz/gruvbox'
" brace closing
Plug 'jiangmiao/auto-pairs'
" easy commenting
Plug 'scrooloose/nerdcommenter'
" deoplete for autocomplete
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
call plug#end()

" Use deoplete.
let g:deoplete#enable_at_startup = 1

let g:airline_theme = 'gruvbox'
let g:gitgutter_terminal_reports_focus=0
let g:gitgutter_realtime=1
let g:gitgutter_eager=1
set updatetime=50

" ----------------------------------------------------------------------
" ---------------------------- vim settings ----------------------------
" ----------------------------------------------------------------------

colorscheme gruvbox
set background=dark
set mouse=a
set number
set cursorline
set colorcolumn=80
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent
set scrolloff=10
set ruler
syntax on
set showmatch
set showcmd
filetype plugin on
let mapleader = "\<Space>"
let g:deoplete#enable_at_startup = 1

" ----------------------------------------------------------------------
" ------------------------- nerd tree settings -------------------------
" ----------------------------------------------------------------------

" open nerdtree tab by default when opening a directory with vim
" Note: running `vim .` will open nerdtree but just running `vim` won't
let g:nerdtree_tabs_open_on_console_startup=2

" ----------------------------------------------------------------------
" ----------------------- nerd commenter settings ----------------------
" ----------------------------------------------------------------------

" add a single space after comment delimeters
let g:NERDSpaceDelims = 1
" use compact syntax for multi-line comments
let g:NERDCompactSexyComs = 1
" comment delimeters appear flush left regardless of indenation
let g:NERDDefaultAlign = 'left'
" trim trailing whitespace after commenting/uncommenting
let g:NERDTrimTrailingWhitespace = 1
" comment/uncomment even empty lines
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" allow toggling to check all selected lines, not just the first
let g:NERDToggleCheckAllLines = 1

" ----------------------------------------------------------------------
" ------------------------ line number settings ------------------------
" ----------------------------------------------------------------------

" use relative numbering (easier for some vim commands)
set number relativenumber

" ----------------------------------------------------------------------
" ------------------------- custom key bindings ------------------------
" ----------------------------------------------------------------------

" use ; to toggle nerd tree view
map ; :NERDTreeToggle<CR>
" use " for Ctrl-p
map " :CtrlP<CR>

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
