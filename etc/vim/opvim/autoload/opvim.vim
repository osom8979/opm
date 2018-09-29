" OPM-VIM PLUGIN AUTOLOAD.

" Python directory. (see also: filename-modifiers)
let s:python_dir = expand('<sfile>:p:h:h') . '/python'
let s:python_until_eof = has('python3') ? 'python3 << EOF' : 'python << EOF'
let s:python_command = has('python3') ? 'py3 ' : 'py '

function! s:Pyeval(eval_string)
    if has('python3')
        return py3eval(a:eval_string)
    endif
    return pyeval(a:eval_string)
endfunction

function! opvim#Initialize() abort
exec s:python_until_eof
import sys
import vim
sys.path.insert(0, vim.eval('s:python_dir'))
global opvim
import opvim
opvim.init()
EOF
endfunction

function! opvim#Preview(show_error) abort
    call s:Pyeval('opvim.preview(' . (a:show_error?'1':'0') . ')')
endfunction

function! opvim#Exec(...) abort
    if a:0 > 0
        call s:Pyeval('opvim.preview(' . a:1 . ')')
    else
        throw 'Argument required.'
    endif
endfunction

function! opvim#Mode(...) abort
    if a:0 > 0
        let g:opvim_project_mode = a:1
    else
        call s:Pyeval('opvim.autoMode()')
    endif
endfunction

function! opvim#CMake() abort
    call s:Pyeval('opvim.cmake()')
endfunction

function! opvim#Build(...) abort
    call s:Pyeval('opvim.build(' . (a:0>0?a:1:'') . ')')
endfunction

function! opvim#Debug(...) abort
    call s:Pyeval('opvim.debug(' . (a:0>0?a:1:'') . ')')
endfunction

function! opvim#Script(...) abort
    call s:Pyeval('opvim.script(' . (a:0>0?a:1:'') . ')')
endfunction

function! opvim#UpdateQuickMenu() abort
    call s:Pyeval('opvim.updateQuickMenu()')
endfunction

function! opvim#UpdateQuickMenuMode() abort
    call s:Pyeval('opvim.updateQuickMenuMode()')
endfunction

