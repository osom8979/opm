" Osom Project Manager for VIM
" PLUGIN AUTOLOAD.

" Python directory. (see also: filename-modifiers)
let s:python_dir = expand('<sfile>:p:h:h') . '/python'
let s:python_until_eof = has('python3') ? 'python3 << EOF' : 'python << EOF'
let s:python_command = has('python3') ? 'py3 ' : 'py '
let s:lua_until_eof = 'lua << EOF'

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

let s:opvim_current_mode = ''

function! opvim#Initialize() abort
    " ...
endfunction

