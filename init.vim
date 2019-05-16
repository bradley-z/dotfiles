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
" ncm2 for autocomplete
" assuming you're using vim-plug: https://github.com/junegunn/vim-plug
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" NOTE: you need to install completion sources to get completions. Check
" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-jedi'
Plug 'ncm2/ncm2-pyclang'
" ALE for linting
Plug 'w0rp/ale'
call plug#end()

let g:airline_theme = 'gruvbox'
let g:gitgutter_terminal_reports_focus=0
let g:gitgutter_realtime=1
let g:gitgutter_eager=1
set updatetime=50

let g:ale_linters = {'cpp': ['clang', 'clang-format'], 'c': ['clang', 'clang-format'], 'python': ['flake8']}

let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}

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
set smarttab
set smartindent
set scrolloff=5
set sidescrolloff=5
set ruler
set backspace=indent,eol,start
syntax on
set showmatch
set encoding=utf-8
set incsearch
set hlsearch
set ignorecase
set smartcase
set nostartofline
set shiftwidth=4
set softtabstop=4
set showtabline=2
set wrapscan
filetype plugin indent on
let mapleader = "\<Space>"
hi LineNr term=bold cterm=bold ctermfg=8 guifg=NONE guibg=NONE

" ----------------------------------------------------------------------
" ------------------------- nerd tree settings -------------------------
" ----------------------------------------------------------------------

" open nerdtree tab by default when opening a directory with vim
" Note: running `vim .` will open nerdtree but just running `vim` won't
let g:nerdtree_tabs_open_on_console_startup=2

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

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

nnoremap <C-j> gT<CR>
nnoremap <C-k> gt<CR>
nnoremap <C-l> :tabc<CR>

" ----------------------------------------------------------------------
" -------------------------- settings for ncm2 -------------------------
" ----------------------------------------------------------------------

" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
au User Ncm2Plugin call ncm2#register_source({
        \ 'name' : 'css',
        \ 'priority': 9,
        \ 'subscope_enable': 1,
        \ 'scope': ['css','scss'],
        \ 'mark': 'css',
        \ 'word_pattern': '[\w\-]+',
        \ 'complete_pattern': ':\s*',
        \ 'on_complete': ['ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
        \ })

let g:ncm2_jedi#python_version = 3
let g:ncm2_pyclang#library_path = '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
