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

function! s:RunPreview() abort
python3 << EOF
import opvim
opvim.preview()
EOF
endfunction

function! s:RunExec(cmds) abort
python3 << EOF
import vim
import opvim
opvim.execute(vim.eval('a:cmds'))
EOF
endfunction

function! s:RunCMake() abort
python3 << EOF
import opvim
opvim.cmake()
EOF
endfunction

function! s:AutoMode() abort
python3 << EOF
import opvim
opvim.autoMode()
EOF
endfunction

"function! s:RunBuild(flags) abort
"python3 << EOF
"import opvim
"opvim.build(vim.eval('a:flags'))
"EOF
"endfunction
"
"function! s:RunDebug(flags) abort
"python3 << EOF
"import opvim
"opvim.debug(vim.eval('a:flags'))
"EOF
"endfunction
"
"function! s:RunTest(flags) abort
"python3 << EOF
"import opvim
"opvim.test(vim.eval('a:flags'))
"EOF
"endfunction

" --------------
" Public script.
" --------------

function! opvim#Initialize()
    if has('nvim') && has('python3')
        call s:InitPython()
    endif
endfunction

function! opvim#Preview()
    call s:RunPreview()
endfunction

function! opvim#Exec(...) abort
    if a:0 > 0
        call s:RunExec(a:1)
    else
        throw 'Argument required.'
    endif
endfunction

function! opvim#Mode(...)
    if a:0 > 0
        let g:opvim_project_mode = a:1
    else
        call s:AutoMode()
    endif
endfunction

function! opvim#CMake() abort
    call s:RunCMake()
endfunction

"function! opvim#Build(...) abort
"    let flags = a:0 > 0 ? a:1 : ''
"    call s:RunBuild(flags)
"endfunction
"
"function! opvim#Debug(...) abort
"    let flags = a:0 > 0 ? a:1 : ''
"    call s:RunDebug(flags)
"endfunction
"
"function! opvim#Test(...) abort
"    let flags = a:0 > 0 ? a:1 : ''
"    call s:RunTest(flags)
"endfunction
"
"function! opvim#Open(...) abort
"    let flags = a:0 > 0 ? a:1 : ''
"    call s:RunOpen(flags)
"endfunction

