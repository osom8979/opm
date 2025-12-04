" general configurations.

set fileencodings=utf-8,cp949
set encoding=utf-8

" Find file format. (Don't use the 'mac' format)
set fileformats=unix,dos
"set fileformats=unix,dox,mac

if has('unix')
    language messages C
else
    language messages en_US
endif

" Reload menu.
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

"set langmenu=none              " language to use for menu translation.
set  number                     " show line number.
set  ruler                      " cursor information.
set  binary                     " binary print mode.
set  hlsearch                   " highlight on the search result.
set  scrolloff=10               " acquire a vertical scroll space.
set  cursorline                 " show cursor line.
"set cursorcolumn               " show cursor column.
set  tabstop=4                  " tab size.
set  shiftwidth=4               " indent size in '>>' or '<<'
set  softtabstop=4              " indent size when pressing the <TAB> key
set  expandtab                  " tab to space.
set  autoindent                 " auto indent.
"set smartindent                " auto indent.
set  nofoldenable               " no folding.
set  noswapfile                 " no swap file.
"set nobackup                   " no backup.
"set winminheight=10            " The minimal height of a window
"set winminwidth=10             " The minimal width of a window
set  backspace=indent,eol,start " make that backspace key work the way it should
"set clipboard=unnamedplus
"set paste                      " don't use this: (for the SnipMate plugin)
"set textwidth=120              " maximum width of text that is being inserted.
set  colorcolumn=88,100,120     " highlight columns
set  termguicolors              " enables 24-bit rgb color in the TUI.
set  iskeyword=@,48-57,_,192-255

" enable mouse event.
if has('mouse')
    set mouse=a
endif

" theme setting.
"set background=dark
"colorscheme desert
"colorscheme solarized
"colorscheme jellybeans
"colorscheme opvim

" grep setting.
set grepprg=grep\ -Hn\ $*\ '%:p'

" syntax highlight.
if has('syntax')
    syntax on
endif

" win32 shell setting.
if has('win32')
    set shell=$ComSpec
endif

" whitespace setting.
if has('nvim')
    set listchars=eol:¶,tab:»·,trail:·,extends:»,precedes:«,conceal:×,nbsp:·
    set list
endif

" doxygen-syntax
let g:load_doxygen_syntax = 1

" a.vim
let g:alternateExtensions_cpp = "h,hpp,hh"
let g:alternateExtensions_hh = "cpp,cc,cxx"

" NERDCommenter
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

" vim-airline
let g:airline_theme='dark'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" vim-showmarks
let g:showmarks_enable = 1

" tagbar
let g:tagbar_left = 0
let g:tagbar_width = 50

" YouCompleteMe
let g:ycm_confirm_extra_conf = 1
let g:ycm_global_ycm_extra_conf = g:opm_vim_script_dir . "/ycm/ycm_extra_conf.py"
let g:ycm_show_diagnostics_ui = 0

" Gundo
let g:gundo_right = 1
let g:gundo_width = 50
let g:gundo_preview_height = 15
if has('python3')
    let g:gundo_prefer_python3 = 1
endif

" python-mode
let g:pymode_folding = 0
let g:pymode_lint_ignore = 'E203,E221,E266,E272,E301,E302'
let g:pymode_options_max_line_length = 99

" SnipMate
let g:snips_author = $USER

" auto-command setting.
if has('autocmd')
    " Show NERDTree window.
    autocmd VimEnter * NERDTree | wincmd p
    autocmd TabEnter * NERDTree | wincmd p

    " Remove tailing whitespace.
    autocmd FileType c,cpp,go,java,php,python,ruby,vim autocmd BufWritePre <buffer> :%s/\s\+$//e

    " Python: Use 4 spaces
    autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

    " JavaScript: Use 2 spaces
    autocmd FileType javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

    " TypeScript: Use 2 spaces
    autocmd FileType typescript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

    " Go: Use real tab characters (gofmt requirement)
    autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4

    " Makefile: Must use tabs (syntax requirement)
    autocmd FileType make setlocal noexpandtab tabstop=4 shiftwidth=4

    " CMakeLists.txt
    autocmd BufNewFile,BufRead CMakeLists.txt set filetype=cmake

    " Use Windows line endings for bat, cmd files
    autocmd FileType dosbatch setlocal fileformat=dos
    autocmd BufNewFile,BufRead *.bat,*.cmd setlocal fileformat=dos
endif

