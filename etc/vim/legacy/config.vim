"if has('gui_running')
"language messages ko_KR
"endif

" source-explorer
let g:SrcExpl_winHeight = 5
let g:SrcExpl_refreshTime = 100
"let g:SrcExpl_updateTagsCmd = 'ctags --c++-kinds=+p --fields=+iaS --extra=+q'
"let g:SrcExpl_jumpKey = '<ENTER>'
"let g:SrcExpl_gobackKey = '<SPACE>'

" OmniCppComplete
set completeopt-=preview
let OmniCpp_MayCompleteDot      = 1 " autocomplete with .
let OmniCpp_MayCompleteArrow    = 1 " autocomplete with ->
let OmniCpp_MayCompleteScope    = 1 " autocomplete with ::
let OmniCpp_SelectFirstItem     = 2 " select first item (but don't insert)
let OmniCpp_NamespaceSearch     = 2 " search namespaces in this and included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function prototype (i.e. parameters) in popup window
let OmniCpp_LocalSearchDecl     = 1 " don't require special style of function opening braces

" clamp
if has('unix') && substitute(system('uname -s'), '\n', '', '') == 'Darwin'
    let g:clamp_libclang_file = '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
endif

" chromatica.nvim
let g:chromatica#enable_at_startup=1
let g:chromatica#delay_ms = 80
let g:chromatica#use_pch = 1
let g:chromatica#highlight_feature_level = 1
let g:chromatica#responsive_mode = 0
if has('unix') && substitute(system('uname -s'), '\n', '', '') == 'Darwin'
    let g:chromatica#libclang_path = '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
endif

" Mundo
let g:mundo_right = 1
let g:mundo_width = 50
let g:mundo_preview_height = 15

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
    set columns=80     " vim column size.
    "winpos 0 0        " vim window position.
endif

" ctags.vim
"set tagbsearch " binary search
set tags=./tags,tags
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
    " Go to previous (last accessed) window.
    " autocmd VimEnter * wincmd p

    " Show NERDTree window.
    autocmd VimEnter * NERDTree | wincmd p
    "autocmd TabEnter * NERDTree | wincmd p

    " Show Quick-fix window.
    "autocmd VimEnter * copen | wincmd p
    "autocmd TabEnter * copen | wincmd p

    " Show Tagbar window.
    "autocmd TabEnter * Tagbar

    " Remove tailing whitespace.
    autocmd FileType vim,c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :%s/\s\+$//e

    " CMakeLists.txt
    autocmd BufNewFile,BufRead CMakeLists.txt set filetype=cmake
endif

