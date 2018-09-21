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

function! s:RunPreview(show_error) abort
python3 << EOF
import opvim
opvim.preview(int(vim.eval('a:show_error')) is 1)
EOF
endfunction

function! s:RunExec(cmds) abort
python3 << EOF
import vim
import opvim
opvim.execute(vim.eval('a:cmds'))
EOF
endfunction

function! s:AutoMode() abort
python3 << EOF
import opvim
opvim.autoMode()
EOF
endfunction

function! s:RunCMake() abort
python3 << EOF
import opvim
opvim.cmake()
EOF
endfunction

function! s:RunBuild(target) abort
python3 << EOF
import opvim
opvim.build(vim.eval('a:target'))
EOF
endfunction

function! s:RunDebug(debug_key) abort
python3 << EOF
import opvim
opvim.debug(vim.eval('a:debug_key'))
EOF
endfunction

function! s:RunScript(script_key) abort
python3 << EOF
import opvim
opvim.script(vim.eval('a:script_key'))
EOF
endfunction

function! s:UpdateQuickMenu() abort
python3 << EOF
import opvim
opvim.updateQuickMenu()
EOF
endfunction

" --------------
" Public script.
" --------------

function! opvim#Initialize() abort
    if has('nvim') && has('python3')
        call s:InitPython()
    endif
endfunction

function! opvim#Preview(show_error) abort
    call s:RunPreview(a:show_error)
endfunction

function! opvim#Exec(...) abort
    if a:0 > 0
        call s:RunExec(a:1)
    else
        throw 'Argument required.'
    endif
endfunction

function! opvim#Mode(...) abort
    if a:0 > 0
        let g:opvim_project_mode = a:1
    else
        call s:AutoMode()
    endif
endfunction

function! opvim#CMake() abort
    call s:RunCMake()
endfunction

function! opvim#Build(...) abort
    call s:RunBuild(a:0 > 0 ? a:1 : '')
endfunction

function! opvim#Debug(...) abort
    call s:RunDebug(a:0 > 0 ? a:1 : '')
endfunction

function! opvim#Script(...) abort
    call s:RunScript(a:0 > 0 ? a:1 : '')
endfunction

function! opvim#UpdateQuickMenu() abort
    call s:UpdateQuickMenu()
endfunction

