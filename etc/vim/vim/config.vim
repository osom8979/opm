"" Common setting.

set fileencodings=utf-8,cp949
set encoding=utf-8

" Find file format.
" Don't use the mac format
set fileformats=unix,dos
"set fileformats=unix,dox,mac

if has('unix')
    language messages C
else
    language messages en_US
endif

if has('gui_running')
    "language messages ko_KR
endif

" Language to use for menu translation.
"set langmenu=none

" Reload menu.
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

set number " show line number.
set ruler  " cursor information.
set binary " binary print mode.

set hlsearch " highlight on the search result.

set scrolloff=10 " acquire a vertical scroll space.

set cursorline    " show cursor line.
"set cursorcolumn " show cursor column.

set tabstop=4  " tab size.
set expandtab  " tab to space.

set autoindent   " auto indent.
"set smartindent " auto indent.
set shiftwidth=4 " indent size.

set nofoldenable " no folding.

set noswapfile   " no swap file.
"set nobackup    " no backup.

" make that backspace key work the way it should
set backspace=indent,eol,start

"set paste " Don't use this: (for the SnipMate plugin)

" theme setting.
"set background=dark
colorscheme desert

" syntax highlight.
if has('syntax')
syntax on
endif

" win32 shell setting.
if has('win32')
set shell=$ComSpec
endif

" gui font setting.
if has('gui_running')
    if has('gui_win32')
        set guifont=Bitstream_Vera_Sans_Mono:h9:cANSI
        set guifontwide=NanumGothicCoding:h10:cDEFAULT
    elseif has('gui_gtk')
        set guifont=DejaVu\ Sans\ Mono\ 9
        set guifontwide=NanumGothicCoding\ 9
    endif

    " whitespace setting.
    set listchars=eol:¶,tab:»·,trail:·,extends:»,precedes:«,conceal:×,nbsp:·
    set list

    set guioptions-=T  " no toolbar.
    set linespace=0    " vim line space.
    set lines=50       " vim line size.
    set columns=150    " vim column size.
    "winpos 0 0        " vim window position.
endif

" NERDTree
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 25
let g:NERDTreeShowBookmarks = 1
let NERDTreeShowHidden = 1
let NERDTreeIgnore  = ['^\..*', '^\.$', '^\.\.$', '\~$']
let NERDTreeIgnore += ['.*\.[oO]$', '.*\.[eE][xX][eE]$']
let NERDTreeIgnore += ['.*\.pyc']

" vim-airline
let g:airline_theme='dark'
let g:airline_powerline_fonts = 0
let g:airline#extensions#tabline#enabled = 1

" vim-showmarks
let g:showmarks_enable = 1

" tagbar
let g:tagbar_left = 0
let g:tagbar_width = 25

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = "~/.vim/ycm_conf.py"

" source-explorer
let g:SrcExpl_winHeight = 5
let g:SrcExpl_refreshTime = 100
"let g:SrcExpl_updateTagsCmd = 'ctags --c++-kinds=+p --fields=+iaS --extra=+q'
"let g:SrcExpl_jumpKey = '<ENTER>'
"let g:SrcExpl_gobackKey = '<SPACE>'

" Gundo
let g:gundo_right = 1
let g:gundo_width = 25
let g:gundo_preview_height = 15

" python-mode
let g:pymode_folding = 0
let g:pymode_lint_ignore = 'E203,E221,E266,E272,E301,E302'
let g:pymode_options_max_line_length = 99

" OmniCppComplete
set completeopt-=preview
let OmniCpp_MayCompleteDot      = 1 " autocomplete with .
let OmniCpp_MayCompleteArrow    = 1 " autocomplete with ->
let OmniCpp_MayCompleteScope    = 1 " autocomplete with ::
let OmniCpp_SelectFirstItem     = 2 " select first item (but don't insert)
let OmniCpp_NamespaceSearch     = 2 " search namespaces in this and included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function prototype (i.e. parameters) in popup window
let OmniCpp_LocalSearchDecl     = 1 " don't require special style of function opening braces

" SnipMate
"let g:snipMate = {}
"let g:snipMate.scope_aliases = {}
"let g:snipMate.scope_aliases['cpp'] = 'cpp'

" ctags.vim
set tags=./tags,tags
"set tagbsearch " binary search
for fpath in split(globpath("$HOME/.vim/ctags/", '*.tags'), '\n')
    "echom fpath
    "let &tags+=','+fpath
    exe ":set tags+=".fpath
endfo

" cscope.vim
if has('cscope')
    "set cscopetag " use both cscope and ctag
    set csto=0    " cscope db search first.
    set nocsverb  " verbose off.

    for fpath in split(globpath("$HOME/.vim/cscope/", '*.out'), '\n')
        cscope add .fpath
    endfo

    if filereadable('cscope.out')
        cscope add cscope.out
    endif

    if has('quickfix')
        "set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-
    endif

    " show msg when any other cscope db added.
    set csverb " verbose on.
endif

" auto-command setting.
if has('autocmd')
    " Show NERDTree window.
    autocmd VimEnter * NERDTree

    " Go to previous (last accessed) window.
    autocmd VimEnter * wincmd p

    " Show Tagbar window.
    "autocmd VimEnter * Tagbar
endif

