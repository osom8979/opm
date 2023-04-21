" Buffer helper.

" ----------------
" Global variables
" ----------------

if !exists('g:opm_quickfix_height')
    let g:opm_quickfix_height = 12
endif
if !exists('g:opm_terminal_height')
    let g:opm_terminal_height = 12
endif

if !exists('g:opm_move_next_buffer_key')
    let g:opm_move_next_buffer_key = '<M-{>'
endif
if !exists('g:opm_move_prev_buffer_key')
    let g:opm_move_prev_buffer_key = '<M-}>'
endif
if !exists('g:opm_close_buffer_key')
    let g:opm_close_buffer_key = '<leader>w'
endif
if !exists('g:opm_close_all_buffer_key')
    let g:opm_close_all_buffer_key = '<leader>W'
endif

if !exists('g:opm_toggle_quickfix_key')
    let g:opm_toggle_quickfix_key = '<leader><leader>3'
endif
if !exists('g:opm_toggle_terminal_key')
    let g:opm_toggle_terminal_key = '<leader><leader>4'
endif

" ---------
" Utilities
" ---------

function! s:TrimLeft(text)
    return substitute(a:text, '^[ \t]*', '', '')
endfunction

function! s:TrimRight(text)
    return substitute(a:text, '[ \t]*$', '', '')
endfunction

function! s:Trim(text)
    return s:TrimLeft(s:TrimRight(a:text))
endfunction

" -----------------
" Buffer operations
" -----------------

let s:False = 0
let s:True  = 1

let s:QUICKFIX_NAME = '[Quickfix List]'
let s:TERMINAL_REGEX = 'term://.*'

let s:BUFFER_NUM  = 'B_NUM'  " [0:2]
let s:BUFFER_F1   = 'B_F1'   " [3] u
let s:BUFFER_F2   = 'B_F2'   " [4] % #
let s:BUFFER_F3   = 'B_F3'   " [5] a h
let s:BUFFER_F4   = 'B_F4'   " [6] - = R F ?
let s:BUFFER_F5   = 'B_F5'   " [7] + x
let s:BUFFER_NAME = 'B_NAME'
let s:BUFFER_LINE = 'B_LINE'

" Indicators (chars in the same column are mutually exclusive):
" u    an unlisted buffer (only displayed when [!] is used) |unlisted-buffer|
"  %    the buffer in the current window
"  #    the alternate buffer for ":e #" and CTRL-^
"   a    an active buffer: it is loaded and visible
"   h    a hidden buffer: It is loaded, but currently not displayed in a window |hidden-buffer|
"    -    a buffer with 'modifiable' off
"    =    a readonly buffer
"    R    a terminal buffer with a running job
"    F    a terminal buffer with a finished job
"    ?    a terminal buffer without a job: `:terminal NONE`
"     +    a modified buffer
"     x   a buffer with read errors

" u: unlisted
" %: current
" #: alternate
" a: active
" h: hidden
" =: readonly
" +: modified
" x: errors

function! s:GetBufferInfoDictionary(num, f1, f2, f3, f4, f5, name, line)
    return {
        \   s:BUFFER_NUM  : a:num,
        \   s:BUFFER_F1   : a:f1,
        \   s:BUFFER_F2   : a:f2,
        \   s:BUFFER_F3   : a:f3,
        \   s:BUFFER_F4   : a:f4,
        \   s:BUFFER_F5   : a:f5,
        \   s:BUFFER_NAME : a:name,
        \   s:BUFFER_LINE : a:line,
        \}
endfunction

function! s:IsListedBuffer(info)
    if a:info[s:BUFFER_F1] == 'u'
        return s:False
    endif
    return s:True
endfunction

function! s:IsCurrentBuffer(info)
    if a:info[s:BUFFER_F2] == '%'
        return s:True
    endif
    return s:False
endfunction

" The buffer is displayed in a window.  If there is a file for this
" buffer, it has been read into the buffer.  The buffer may have been
" modified since then and thus be different from the file.
" See also: *active-buffer*
function! s:IsActiveBuffer(info)
    if a:info[s:BUFFER_F3] == 'a'
        return s:True
    endif
    return s:False
endfunction

" The buffer is not displayed.  If there is a file for this buffer, it
" has been read into the buffer.  Otherwise it's the same as an active
" buffer, you just can't see it.
" See also: *hidden-buffer*
function! s:IsHiddenBuffer(info)
    if a:info[s:BUFFER_F3] == 'h'
        return s:True
    endif
    return s:False
endfunction

function! s:IsModifiableBuffer(info)
    if a:info[s:BUFFER_F4] == '-'
        return s:False
    endif
    return s:True
endfunction

function! s:IsReadonlyBuffer(info)
    if a:info[s:BUFFER_F4] == '='
        return s:True
    endif
    return s:False
endfunction

function! s:IsTerminalBuffer(info)
    let f4 = a:info[s:BUFFER_F4]
    if f4 == 'R' || f4 == 'F' || f4 == '?'
        return s:True
    endif
    return s:False
endfunction

function! s:FindIndexWithBufferNumber(buffers, number)
    let index = 0
    for cursor in a:buffers
        if cursor[s:BUFFER_NUM] == a:number
            return index
        endif
        let index += 1
    endfor
    return -1
endfunction

function! s:GetBufferInfoDictionaryWithString(text)
    let trim = s:Trim(a:text)
    let num  = matchstr(trim, '^[0-9]*')
    let f1   = trim[strlen(num)+0]
    let f2   = trim[strlen(num)+1]
    let f3   = trim[strlen(num)+2]
    let f4   = trim[strlen(num)+3]
    let f5   = trim[strlen(num)+4]

    let name = strpart(trim, stridx(trim, '"')+1)
    let name = strpart(name, 0, stridx(name, '"'))

    let line = matchstr(trim, '[0-9]*$')
    return s:GetBufferInfoDictionary(
        \   str2nr(num),
        \   f1, f2, f3, f4, f5,
        \   name,
        \   str2nr(line)
        \)
endfunction

function! s:GetCurrentBuffersOutput()
    redir => output
    silent execute 'buffers!'
    redir END
    return output
endfunction

function! s:GetCurrentBufferInfoList()
    let result = []
    for cursor in split(s:GetCurrentBuffersOutput(), '\n')
        let result += [s:GetBufferInfoDictionaryWithString(cursor)]
    endfor
    return result
endfunction

function! s:FindBufferWithName(name)
    for cursor in split(s:GetCurrentBuffersOutput(), '\n')
        let dic = s:GetBufferInfoDictionaryWithString(cursor)
        if dic[s:BUFFER_NAME] == a:name
            return dic
        endif
    endfor
    return {}
endfunction

function! s:FindBufferWithRegexName(regex)
    for cursor in split(s:GetCurrentBuffersOutput(), '\n')
        let dic = s:GetBufferInfoDictionaryWithString(cursor)
        if !empty(matchstr(dic[s:BUFFER_NAME], a:regex))
            return dic
        endif
    endfor
    return {}
endfunction

function! s:GetCurrentModifiableListedBufferInfoList()
    let result = []
    for cursor in split(s:GetCurrentBuffersOutput(), '\n')
        let info = s:GetBufferInfoDictionaryWithString(cursor)
        if s:IsListedBuffer(info) && s:IsModifiableBuffer(info) && !s:IsTerminalBuffer(info)
            let result += [info]
        endif
    endfor
    return result
endfunction

" --------------------
" Quick-fix operations
" --------------------

function! s:FindQuickfixBuffer()
    return s:FindBufferWithName(s:QUICKFIX_NAME)
endfunction

function! s:ExistsQuickfixBuffer()
    let dic = s:FindQuickfixBuffer()
    if empty(dic)
        return s:False
    endif
    return s:IsActiveBuffer(dic)
endfunction

function! s:ToggleQuickfixBuffer(...)
    if s:ExistsQuickfixBuffer()
        let force_enable_show = a:0 > 0 ? a:1 : 0
        if force_enable_show == 0
            silent execute 'cclose'
        endif
    else
        silent execute 'belowright ' . g:opm_quickfix_height . 'copen | wincmd p'
    endif
endfunction

" -------------------
" Terminal operations
" -------------------

function! s:FindTerminalBuffer()
    return s:FindBufferWithRegexName(s:TERMINAL_REGEX)
endfunction

function! s:ToggleTerminalBuffer(...)
    let dic = s:FindTerminalBuffer()
    if !empty(dic) && s:IsActiveBuffer(dic)
        let force_enable_show = a:0 > 0 ? a:1 : 0
        if force_enable_show == 0
            silent execute 'bdelete! ' . dic[s:BUFFER_NUM]
        endif
    else
        silent execute 'topleft ' . g:opm_terminal_height . 'split term://bash -l | startinsert'
    endif
endfunction

" ----------------------
" Main Buffer operations
" ----------------------

function! s:MoveModifiableBuffer(offset)
    let buffers = s:GetCurrentModifiableListedBufferInfoList()
    let size    = len(buffers)
    let index   = s:FindIndexWithBufferNumber(buffers, bufnr('%'))
    let next    = index + a:offset

    if size == 0 || index == -1
        return
    endif

    " Switching another buffer!
    if 0 <= next && next < size
        silent execute 'buffer ' . buffers[next][s:BUFFER_NUM]
    endif
endfunction

function! s:MovePrevModifiableBuffer()
    call s:MoveModifiableBuffer(-1)
endfunction

function! s:MoveNextModifiableBuffer()
    call s:MoveModifiableBuffer(1)
endfunction

function! s:CloseAndMoveNextBuffer()
    let buffers = s:GetCurrentModifiableListedBufferInfoList()
    let size    = len(buffers)
    let index   = s:FindIndexWithBufferNumber(buffers, bufnr('%'))

    if size == 0 || index == -1
        return
    endif

    let next = -1
    if index + 1 < size
        let next = index + 1
    elseif index - 1 >= 0
        let next = index - 1
    endif

    " Switching another buffer!
    if next != -1
        silent execute 'buffer ' . buffers[next][s:BUFFER_NUM]
    endif
    silent execute 'bdelete! ' . buffers[index][s:BUFFER_NUM]
endfunction

function! s:CloseAnotherBuffer()
    let buffers = s:GetCurrentModifiableListedBufferInfoList()
    let size    = len(buffers)
    let current = bufnr('%')
    let index   = s:FindIndexWithBufferNumber(buffers, current)

    if size == 0 || index == -1
        return
    endif

    for cursor in buffers
        if cursor[s:BUFFER_NUM] != current
            silent execute 'bdelete! ' . cursor[s:BUFFER_NUM]
        endif
    endfor
endfunction

" -----------
" Key mapping
" -----------

function! OpmMoveNextBuffer()
    call s:MovePrevModifiableBuffer()
endfunction

function! OpmMovePrevBuffer()
    call s:MoveNextModifiableBuffer()
endfunction

function! OpmCloseBuffer()
    call s:CloseAndMoveNextBuffer()
endfunction

function! OpmCloseAllBuffer()
    call s:CloseAnotherBuffer()
endfunction

silent execute 'noremap '.g:opm_move_next_buffer_key.' <ESC>:call OpmMoveNextBuffer()<CR>'
silent execute 'noremap '.g:opm_move_prev_buffer_key.' <ESC>:call OpmMovePrevBuffer()<CR>'
silent execute 'noremap '.g:opm_close_buffer_key    .' <ESC>:call OpmCloseBuffer()<CR>'
silent execute 'noremap '.g:opm_close_all_buffer_key.' <ESC>:call OpmCloseAllBuffer()<CR>'

function! OpmToggleQuickfixBuffer()
    call s:ToggleQuickfixBuffer()
endfunction

function! OpmToggleTerminalBuffer()
    call s:ToggleTerminalBuffer()
endfunction

silent execute 'noremap '.g:opm_toggle_quickfix_key.' <ESC>:call OpmToggleQuickfixBuffer()<CR>'
silent execute 'noremap '.g:opm_toggle_terminal_key.' <ESC>:call OpmToggleTerminalBuffer()<CR>'

