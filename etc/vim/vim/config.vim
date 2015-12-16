"" Common setting.

set fileencodings=utf-8,cp949
set encoding=utf-8

" Find file format.
" Don't use the mac format
set fileformats=unix,dos
"set fileformats=unix,dox,mac

if has("gui_running")
language message en_US
"language message ko_KR
endif

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

" theme setting.
"set background=dark
colorscheme desert

" syntax highlight.
if has("syntax")
syntax on
endif

" win32 shell setting.
if has('win32')
set shell=$ComSpec
endif

" gui font setting.
if has("gui_running")
    set guifont=Bitstream_Vera_Sans_Mono:h9:cANSI
    set guifontwide=NanumGothicCoding:h10:cDEFAULT

    " whitespace setting.
    set listchars=eol:¶,tab:»·,trail:·,extends:»,precedes:«,conceal:×,nbsp:·
    set list

    set lines=50     " vim line size.
    set columns=150  " vim column size.
    winpos 0 0       " vim window position.
endif

" NERDTree
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 25
let g:NERDTreeShowBookmarks = 1
let NERDTreeShowHidden = 1
let NERDTreeIgnore  = ['^\.$', '^\.\.$', '\~$']
let NERDTreeIgnore += ['.*\.[oO]$', '.*\.[eE][xX][eE]$']

" vim-airline
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
let g:SrcExpl_updateTagsCmd = "ctags --c++-kinds=+p --fields=+iaS --extra=+q"
let g:SrcExpl_refreshTime = 100
"let g:SrcExpl_jumpKey = "<ENTER>"
"let g:SrcExpl_gobackKey = "<SPACE>"

" Gundo
let g:gundo_right = 1
let g:gundo_width = 25
let g:gundo_preview_height = 15

" ctags.vim
set tags =./tags,tags
"set tagbsearch " binary search
for fpath in split(globpath('$HOME/.cache/ctags/', '*.tags'), '\n')
    "echom fpath
    "let &tags+=','+fpath
    exe ":set tags+=".fpath
endfo

" cscope.vim
if has("cscope")
    set cscopetag " use both cscope and ctag
    set csto=0    " cscope db search first.
    " set nocsverb  " verbose off.

    for fpath in split(globpath('$HOME/.cache/cscope/', '*.out'), '\n')
        " cscope add .fpath
    endfo

    if filereadable("cscope.out")
        cscope add cscope.out
    endif

    " show msg when any other cscope db added
    set csverb
endif

if exists("g:pymode")
    let g:pymode_folding = 0
endif

" auto-command setting.
if has("autocmd")
    " Show NERDTree window.
    autocmd VimEnter * NERDTree

    " Go to previous (last accessed) window.
    autocmd VimEnter * wincmd p

    " Show Tagbar window.
    "autocmd VimEnter * Tagbar

    " Show SourceExplorer window.
    "autocmd VimEnter * SrcExpl
endif

