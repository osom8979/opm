" Osom Project Manager for VIM
" PLUGIN AUTOLOAD.

" Python directory. (see also: filename-modifiers)
let s:python_dir = expand('<sfile>:p:h:h') . '/python'
let s:python_until_eof = has('python3') ? 'python3 << EOF' : 'python << EOF'
let s:python_command = has('python3') ? 'py3 ' : 'py '

let s:breakpoint_window_name = '[OPVIM>BREAKPOINT]'

sign define OpvimBreakpointEnable   text=●
sign define OpvimBreakpointDisable  text=○
sign define OpvimCurrentLine        text=⇒

function! s:Pyeval(eval_string)
    if has('python3')
        return py3eval(a:eval_string)
    endif
    return pyeval(a:eval_string)
endfunction

function! s:EchoWarning(message)
    echohl WarningMsg
    echo a:message
    echohl None
endfunction

function! s:JoinStringList(string_list)
    if len(a:string_list) == 0
        return ''
    else
        let total_message = a:string_list[0]
        if len(a:string_list) > 1
            for line in a:string_list[1:]
                let total_message .= "\n" . line
            endfor
        endif
        return total_message
    endif
endfunction

" -----------
" breakpoints
" -----------

function! s:GetCurrentAbsolutePath()
    return expand('%:p')
endfunction

function! s:GetCurrentLineNumber()
    return line('.')
endfunction

function! s:GetCurrentBreakpoint()
    return s:GetCurrentAbsolutePath() . "\t" . s:GetCurrentLineNumber()
endfunction

" ------------
" opvim prefix
" ------------

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
" 4. (SKIP) server & debugger handshake
" 5. [WORKING] ...
" 6-1. if debugger dead
"  * {on_exit} callback
"  * server jobstop()
" 6-2. if dead request
"  * request debugger kill
"  * debugger dead
"  * {on_exit} callback
" 6-3. if dead from user request
"  * write debugger kill to FIFO
"  * debugger dead
"  * {on_exit} callback
" 7. kill fifo server.
" 8. {on_exit} callback from the fifo server.
" 9. unlink FIFO

function! opvim#OnDebuggerExit(job_id, data, event)
    call jobstop(g:opvim_debugging_fifo_server_id)
    let g:opvim_debugging_fifo_server_id = 0
endfunction

function! opvim#OnDebuggerFifoStdout(job_id, data, event)
exec s:python_until_eof
import vim
opvim.onFifoLogging('[OUT] ', vim.eval('s:JoinStringList(a:data)'))
EOF
endfunction

function! opvim#OnDebuggerFifoStderr(job_id, data, event)
exec s:python_until_eof
import vim
opvim.onFifoLogging('[ERR] ', vim.eval('s:JoinStringList(a:data)'))
EOF
endfunction

function! opvim#OnDebuggerFifoExit(job_id, data, event)
    echo 'Debugging done. (job_id:' . a:job_id . ', exit:' . a:data . ')'
endfunction

function! opvim#ExitDebug()
    "call rpcrequest(g:opvim_cache_debugging_job_id, 'exit')
endfunction

function! opvim#UpdateViewWindow()
    " Buffer-local options
    setlocal filetype=opvim " Vim can detect the type of file that is edited.
    setlocal noreadonly     " in case the "view" mode is used
    setlocal buftype=nofile " The value of this option specifies the type of a buffer.
    setlocal bufhidden=hide " Hide the buffer (don't unload it)
    setlocal noswapfile     " Do not create a swapfile.
    setlocal nobuflisted    " Hide in the buffer list.
    setlocal nomodifiable   " Buffer contents cannot be changed.
    setlocal textwidth=0    " Disable maximum width of text that is being inserted.

    " Window-local options
    setlocal nolist
    setlocal nowrap
    setlocal winfixheight
    setlocal nospell
    setlocal nonumber

    " Fold options.
    setlocal nofoldenable
    setlocal foldcolumn=0
endfunction

function! opvim#OpenBreakpointWindow()
    exe 'silent keepalt topleft 10new ' . s:breakpoint_window_name
endfunction

