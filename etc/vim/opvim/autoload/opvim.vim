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

function! s:RunExec(flags) abort
python3 << EOF
import opvim
opvim.execute(vim.eval('a:flags'))
EOF
endfunction

function! s:RunCMake(flags) abort
python3 << EOF
import opvim
opvim.cmake(vim.eval('a:flags'))
EOF
endfunction

function! s:RunBuild(flags) abort
python3 << EOF
import opvim
opvim.build(vim.eval('a:flags'))
EOF
endfunction

function! s:RunDebug(flags) abort
python3 << EOF
import opvim
opvim.debug(vim.eval('a:flags'))
EOF
endfunction

function! s:RunTest(flags) abort
python3 << EOF
import opvim
opvim.test(vim.eval('a:flags'))
EOF
endfunction

function! s:RunOpen(flags) abort
python3 << EOF
import opvim
opvim.open(vim.eval('a:flags'))
EOF
endfunction

function! s:RunPreview()
python3 << EOF
import opvim
opvim.preview()
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

function! opvim#Exec(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunExec(flags)
endfunction

function! opvim#CMake(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunCMake(flags)
endfunction

function! opvim#Build(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunBuild(flags)
endfunction

function! opvim#Debug(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunDebug(flags)
endfunction

function! opvim#Test(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunTest(flags)
endfunction

function! opvim#Open(...) abort
    let flags = a:0 > 0 ? a:1 : ''
    call s:RunOpen(flags)
endfunction

function! opvim#Mode(...)
    if a:0 > 0
        let g:opvim_project_mode = a:1
    else
        echo g:opvim_project_mode
    endif
endfunction

function! opvim#Preview()
    call s:RunPreview()
endfunction

