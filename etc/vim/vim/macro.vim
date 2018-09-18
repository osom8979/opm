"" Macro setting.

let s:False = 0
let s:True  = 1

function! TrimLeft(text)
    return substitute(a:text, '^[ \t]*', '', '')
endfunction

function! TrimRight(text)
    return substitute(a:text, '[ \t]*$', '', '')
endfunction

function! Trim(text)
    return TrimLeft(TrimRight(a:text))
endfunction

"" ------------------
"" String operations.
"" ------------------

function! RemoveCr()
    silent execute '%s/$//g'
endfunction

"" -----------------
"" Buffer operations.
"" -----------------

let s:BUFFER_NUM  = 'B_NUM'
let s:BUFFER_F1   = 'B_F1'
let s:BUFFER_F2   = 'B_F2'
let s:BUFFER_F3   = 'B_F3'
let s:BUFFER_F4   = 'B_F4'
let s:BUFFER_F5   = 'B_F5'
let s:BUFFER_NAME = 'B_NAME'
let s:BUFFER_LINE = 'B_LINE'

function! GetBufferInfoDictionary(num, f1, f2, f3, f4, f5, name, line)
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

function! IsListedBuffer(info)
    if a:info[s:BUFFER_F1] == 'u'
        return s:False
    endif
    return s:True
endfunction

function! IsCurrentBuffer(info)
    if a:info[s:BUFFER_F2] == '%'
        return s:True
    endif
    return s:False
endfunction

function! IsActiveBuffer(info)
    if a:info[s:BUFFER_F3] == 'a'
        return s:True
    endif
    return s:False
endfunction

function! IsHiddenBuffer(info)
    if a:info[s:BUFFER_F3] == 'h'
        return s:True
    endif
    return s:False
endfunction

function! IsModifiableBuffer(info)
    if a:info[s:BUFFER_F4] == '-'
        return s:False
    endif
    return s:True
endfunction

function! IsReadonlyBuffer(info)
    if a:info[s:BUFFER_F4] == '='
        return s:True
    endif
    return s:False
endfunction

function! FindIndexWithBufferNumber(buffers, number)
    let index = 0
    for cursor in a:buffers
        if cursor[s:BUFFER_NUM] == a:number
            return index
        endif
        let index += 1
    endfor
    return -1
endfunction

function! GetBufferInfoDictionaryWithString(text)
    let trim = Trim(a:text)
    let num  = matchstr(trim, '^[0-9]*')
    let f1   = trim[strlen(num)+0]
    let f2   = trim[strlen(num)+1]
    let f3   = trim[strlen(num)+2]
    let f4   = trim[strlen(num)+3]
    let f5   = trim[strlen(num)+4]

    let name = strpart(trim, stridx(trim, '"')+1)
    let name = strpart(name, 0, stridx(name, '"'))

    let line = matchstr(trim, '[0-9]*$')
    return GetBufferInfoDictionary(
        \   str2nr(num),
        \   f1, f2, f3, f4, f5,
        \   name,
        \   str2nr(line)
        \)
endfunction

function! GetCurrentBuffersOutput()
    redir => output
    silent execute 'buffers!'
    redir END
    return output
endfunction

function! GetCurrentBufferInfoList()
    let result = []
    for cursor in split(GetCurrentBuffersOutput(), '\n')
        let result += [GetBufferInfoDictionaryWithString(cursor)]
    endfor
    return result
endfunction

function! GetCurrentModifiableListedBufferInfoList()
    let result = []
    for cursor in split(GetCurrentBuffersOutput(), '\n')
        let info = GetBufferInfoDictionaryWithString(cursor)
        if IsListedBuffer(info) && IsModifiableBuffer(info)
            let result += [info]
        endif
    endfor
    return result
endfunction

"" -----------------------
"" Main Buffer operations.
"" -----------------------

function! MoveModifiableBuffer(offset)
    let buffers = GetCurrentModifiableListedBufferInfoList()
    let size    = len(buffers)
    let index   = FindIndexWithBufferNumber(buffers, bufnr('%'))
    let next    = index + a:offset

    if size == 0 || index == -1
        return
    endif

    " Switching another buffer!
    if 0 <= next && next < size
        silent execute 'buffer ' . buffers[next][s:BUFFER_NUM]
    endif
endfunction

function! MovePrevModifiableBuffer()
    call MoveModifiableBuffer(-1)
endfunction

function! MoveNextModifiableBuffer()
    call MoveModifiableBuffer(1)
endfunction

function! CloseAndMoveNextBuffer()
    let buffers = GetCurrentModifiableListedBufferInfoList()
    let size    = len(buffers)
    let index   = FindIndexWithBufferNumber(buffers, bufnr('%'))

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
    silent execute 'bdelete ' . buffers[index][s:BUFFER_NUM]
endfunction

function! CloseAnotherBuffer()
    let buffers = GetCurrentModifiableListedBufferInfoList()
    let size    = len(buffers)
    let current = bufnr('%')
    let index   = FindIndexWithBufferNumber(buffers, current)

    if size == 0 || index == -1
        return
    endif

    for cursor in buffers
        if cursor[s:BUFFER_NUM] != current
            silent execute 'bdelete ' . cursor[s:BUFFER_NUM]
        endif
    endfor
endfunction

function! PrintHelpMessage()
    let lines = readfile(g:opm_vim_script_dir . '/help.txt')
    for line in lines
        echo line
    endfor
endfunction

