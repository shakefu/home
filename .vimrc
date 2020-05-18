"
" Jake's .vimrc
"
" Not intended for public consumption. Use at your own risk.
"
" Version 20160210
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

" Load pathogen
filetype off

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on


"""""""""""""""""""""""""
" Tab completion settings
"
" The following three groups of settings make Tab completion play nicely.
"

" SuperTab settings
" let g:SuperTabDefaultCompletionType = "context"
" let g:SuperTabLongestEnhanced = 1
" let g:SuperTabLongestHighlight = 1
" let g:SuperTabClosePreviewOnPopupClose = 1

" Jedi settings
" let g:jedi#popup_on_dot = 0
" let g:jedi#documentation_command = "K"
" let g:jedi#show_call_signatures = "0"

" Omnicomplete settings
" set completeopt=longest,menu
" set wildmode=longest,list:longest
" let g:omni_syntax_ignorecase = 0


"""""""""""""""""""""""
" Other plugin settings
"

" CtrlP settings
set wildignore+=*.pyc,*.pyo,*/node_modules/*,*/bower/*,*/__pycache__/*
" Makes CtrlP open selected files in new tabs instead of same buffer
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>', '<2-LeftMouse>'],
    \ 'AcceptSelection("t")': ['<cr>'],
\ }

" ProjectRoot settings
" Change to the project root of the current buffer when switching
au WinEnter * if &ft != 'help' | call ProjectRootCD() | endif

" vim-markdown settings
" Highlight fenced code blocks GitHub style
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']

" YouCompleteMe settings
" Change the number of chars before showing completion menu
let g:ycm_min_num_of_chars_for_completion = 2
" Number of characters required in ID (identifier) matches
let g:ycm_min_num_identifier_candidate_chars = 0
" Change to 1 to enable completion inside comments
let g:ycm_complete_in_comments = 0
" Change to 1 to enable completion inside strings
let g:ycm_complete_in_strings = 0
" Don't populate completion with Syntax from filetype
let g:ycm_seed_identifiers_with_syntax = 0
" Close the preview window on completion
let g:ycm_autoclose_preview_window_after_completion = 1
" Close the preview window on insertion
let g:ycm_autoclose_preview_window_after_insertion = 1
" Select the highlighted completion on Enter
" let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']

" Powerline
" Enable Powerline
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
" Always show Powerline
set laststatus=2

" Pymode
" Use Python3
let g:pymode_python = "python3"
" Enable virtualenvs
let g:pymode_virtualenv = 1
" Disable linting
let g:pymode_lint = 0

" Syntastic settings
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

" Disable HTML checking
" let g:syntastic_html_checkers=['']

" Disable syntastic unless explicitly enabled
" let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 0
" let g:syntastic_check_on_wq = 0

" JSX highlighting
" let g:jsx_ext_required = 0


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

" CoffeeScript shortcuts (unused)
" Execute the current coffeescript buffer
" map <Leader>a :ExecuteBuffer<Enter>
" Execute the current coffeescript selection
" map <Leader>s :ExecuteSelection<Enter>
" Run grunt test suite in a Conque split - probably should make this more
" generic at some point, since it's specific to Retaliator right now
" map <Leader>t :ConqueTermSplit grunt coffeelint:lib coffee:lib mochaTest<CR>

" Diff the currently open panes
map <Leader>f :windo diffthis<Enter>
map <Leader>ff :diffoff!<Enter>

" Show documentation for word under cursor if it exists
map <Leader>D :call pymode#doc#find()<Enter>

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

" Highlight python syntax
let python_highlight_all=1
syntax on

" Filetype based auto indenting
filetype indent on

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

" Highlight .litcoffee correctly
autocmd FileType litcoffee runtime ftplugin/coffee.vim

" reStructuredText has 3 spaces instead of 4
au FileType rst setlocal tabstop=3 shiftwidth=3
au BufNewFile,BufRead *.rest set filetype=rst

" Use four spaces for Javascript
au FileType javascript setlocal tabstop=4 shiftwidth=4


""""""""""""""""""""""""""""""""""""
" Bad whitespace matching for Python

" Match all tabs at the begging of a line as bad
" Match trailing whitespace as bad
" Match lines containing only whitespace as bad
" In diff_mode, ignore lines containing just a single space (diff adds these)
let diff_mode=0
au FileType diff let diff_mode=1
function! MatchWhitespace()
    if !g:diff_mode
        match BadWhitespace /^\t\+/
        match BadWhitespace /\s\+$/
        match BadWhitespace /\S\s\+$/
        match BadWhitespace /^ \+$/
        match BadWhitespace / \+$/
    else
        match BadWhitespace /^\t\+/
        match BadWhitespace /\s\{2,\}$/
        match BadWhitespace /\S\s\+$/
        match BadWhitespace /^ \{2,\}$/
        match BadWhitespace / \{2,\}$/
    endif
endfunction

" Highlight trailing whitespace
au BufEnter,BufWinEnter,StdinReadPost *.py,*.sh,*.coffee,*.js,*.html,*.rst,*.md call MatchWhitespace()


""""""""""""""""""""""""""""""""""""
" Highlight lines over 80 characters

function! LongLines()
    if exists('+colorcolumn')
        setlocal colorcolumn=80
    else
        " au BufWinEnter * let w:m2=matchadd('LongLine', '\%>80v.\+', -1)
        au BufEnter,BufWinEnter,StdinReadPost *.py,*.sh match LongLine /\%>80v.\+/
    endif
endfunction

" Only highlight long lines in Python, for now
au BufEnter,BufWinEnter * call LongLines()


""""""""""""""""
" netrw settings

" Change file sort pattern
let g:netrw_sort_sequence='[\/]$,\<core\%(\.\d\+\)\=,\.[a-np-z]$,\.h$,\.c$,\.cpp$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\.pyc$,\~$'
" Open files in splits
let g:netrw_browse_split=2
" Use tree listing by default
let g:netrw_liststyle=3
" Hide .pyc, .orig, .swp, .swo
let g:netrw_list_hide='\.pyc$,\.orig$,\.swp$,\.swo$'


""""""""""""""""""""""""
" Set directory settings
set directory=~/tmp/vim,/var/tmp,/tmp


