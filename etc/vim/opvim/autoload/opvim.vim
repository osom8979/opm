" Osom Project Manager for VIM
" PLUGIN AUTOLOAD.

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
        call s:Pyeval('opvim.execute("' . a:1 . '")')
    else
        throw 'Argument required.'
    endif
endfunction

function! opvim#Mode(...) abort
    call s:Pyeval('opvim.setMode("' . (a:0>0?a:1:'') . '")')
endfunction

function! opvim#GetMode(...) abort
    return s:Pyeval('opvim.getMode()')
endfunction

function! opvim#CMake() abort
    call s:Pyeval('opvim.cmake()')
endfunction

function! opvim#Build(...) abort
    call s:Pyeval('opvim.build("' . (a:0>0?a:1:'') . '")')
endfunction

function! opvim#Debug(...) abort
    call s:Pyeval('opvim.debug("' . (a:0>0?a:1:'') . '")')
endfunction

function! opvim#Script(...) abort
    call s:Pyeval('opvim.script("' . (a:0>0?a:1:'') . '")')
endfunction

function! opvim#UpdateQuickMenu() abort
    call s:Pyeval('opvim.updateQuickMenu()')
endfunction

function! opvim#UpdateQuickMenuMode() abort
    call s:Pyeval('opvim.updateQuickMenuMode()')
endfunction

" --------
" Debugger
" --------

" How to work:
" LLDB(GDB) <-{stdio}-> |FIFO| <-{stdio}-> Server(PYTHON) <-{callback}-> vim
"
" Work process:
" 1. create FIFO
" 2. start fifo server
" 3. start debugger (LLDB or GDB)
" 4. server & debugger handshake
" 5. [WORKING] ...
" 6-1. if debugger dead
"  * {on_exit} callback
" 6-2. if dead request
"  * request debugger kill
"  * debugger dead
"  * {on_exit} callback
" 7. kill fifo server.
" 8. {on_exit} callback from the fifo server.
" 9. unlink FIFO

function! opvim#OnDebuggerFifoExit(job_id, data, event)
    echo 'Call opvim#OnDebuggerFifoExit() !!'
endfunction

function! opvim#OnDebuggerExit(job_id, data, event)
    "call s:Pyeval('opvim.onDebuggerExit()')
    echo 'Call opvim#OnDebuggerExit() !!'
    call jobstop(g:opvim_cache_debugging_fifo_server_job_id)
endfunction

function! opvim#ExitDebug()
    "call rpcrequest(g:opvim_cache_debugging_job_id, 'exit')
endfunction

