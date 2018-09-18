" OPM-VIM PLUGIN AUTOLOAD.

" ---------------
" Private script.
" ---------------

" Python directory.
let s:opvim_autoload_dir = expand('<sfile>:p:h')

function! s:InitPython() abort
python3 << EOF
import sys
import vim
OPVIM_AUTOLOAD_DIR = vim.eval('s:opvim_autoload_dir')
sys.path.insert(0, OPVIM_AUTOLOAD_DIR)
import opvim
opvim.init()
EOF
endfunction

function! s:RunCMake(flags) abort
python3 << EOF
import opvim
opvim.runCMake(vim.eval('a:flags'))
EOF
endfunction

" --------------
" Public script.
" --------------

function! opvim#Initialize()
    if has('nvim') && has('python3')
        call s:InitPython()
    endif
endfunction

function! opvim#CMake(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunCMake(flags)
endfunction

