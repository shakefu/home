"
" Jake's .vimrc
"
" Not intended for public consumption. Use at your own risk.
"
" Version 20231117
"
" This version has been rewritten to work primarily with VSCode
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remove all autocommands
" autocmd!

" Make shit verbose
" set verbose=9

" Re source .vimrc whenever it's edited
au! BufWritePost $MYVIMRC source $MYVIMRC


"""""""""
" Plugins

filetype plugin indent on
syntax on


""""""""""""""
" Key mappings

" Remap Ctrl-C to Esc during insert mode so we don't skip trigging InsertLeave
" events
inoremap <C-c> <Esc>

" Change the leader to '
let mapleader = "'"

" Make '' (jump to previous line) still work fast even though it uses leader
map <Leader><Leader> ''
" Merge the current tab and right tab in a vertical split
map <Leader>l :Tabmerge right<Enter>

" Diff the currently open panes
map <Leader>f :windo diffthis<Enter>
map <Leader>ff :diffoff!<Enter>

" Find the definition of the word under the cursor in same file types (really
" only works for Python at the moment.)
map <Leader>d :execute "silent grep! -srnwIE --exclude-dir=.git " .
        \ "--exclude-dir=test --exclude-dir=tpm --include=*" . expand("%:e") .
        \ " -e 'def " . expand("<cword>") . "' -e 'class " . expand("<cword>") .
        \ "' ." <Bar> cwindow<CR>
au BufReadPost quickfix map <buffer> <CR> <C-W><CR>:cclose<CR>"

" Comment out all lines with '# '
map <Leader># :norm ^i# <CR>
" Delete first two charaters (e.g. '# ')
map <Leader>3 :norm ^xx<CR>


""""""""""""""
" Color scheme

if has("gui_running")
    " Set our colorscheme (the most important thing, that's why we do it first
    colorscheme ir_black
    set transparency=20

    " Zenburn
    " let g:zenburn_high_Contrast = 1
    " colorscheme zenburn
    " set transparency=10

    " Solarized
    " colorscheme solarized
    " set background=dark
    " set transparency=0
endif

" Change highlight fold colors
highlight Folded ctermfg=darkgrey ctermbg=none

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Highlight long lines
highlight LongLine ctermbg=darkblue guibg=darkblue

" Highlight current line and column
" a.k.a. 'Where the crap is my cursor?'
set cursorline cursorcolumn
au WinEnter * setlocal cursorline cursorcolumn
au WinLeave * setlocal nocursorline nocursorcolumn
" These settings work for console vim
" highlight CursorLine cterm=bold
" highlight CursorColumn cterm=bold ctermbg=none


"""""""
" Font
if has("gui_running")
    " set guifont=Menlo\ Regular:h12
    set guifont=Noto\ Mono\ for\ Powerline:h12
endif


""""""""""""""""""""""
" Editing conveniences

" Don't beep when I relentlessly mash ESC/CtrlC
set visualbell

" Keep cursor vertically centered at all times
set scrolloff=999
" Cursor wrapping
set whichwrap=b,s,h,l,<,>,[,]
" Don't wrap long lines
set nowrap
" Line numbers
set number
" Highlight search terms
set hlsearch
" Search as you type
set incsearch
" Show ruler
set ruler

" Switch current local window's directory to that of the edited file
" This is disabled 'cause it screws with tab labelling dynamically
" autocmd BufEnter * silent! lcd %:p:h

" Handle newlines forcefully
set ffs=unix
set encoding=utf-8
set fileencoding=utf-8


""""""""""""""""""
" Syntax specifics

" Folding based on indent
set foldmethod=indent

" Setup tabbing/spaces
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Use two spaces for CoffeeScript, JSON and HTML
au FileType coffee setlocal tabstop=2 shiftwidth=2
au FileType html setlocal tabstop=2 shiftwidth=2
au FileType json setlocal tabstop=2 shiftwidth=2
au FileType yaml setlocal tabstop=2 shiftwidth=2

" reStructuredText has 3 spaces instead of 4
au FileType rst setlocal tabstop=3 shiftwidth=3
au BufNewFile,BufRead *.rest set filetype=rst

" Use four spaces for Javascript
au FileType javascript setlocal tabstop=4 shiftwidth=4
