"" Macro setting.

function! OpmHelp()
    echom 'OPM HELP!'
endfunction

function! TrimLeft(text)
    return substitute(a:text, '^[ \t]*', '', '')
endfunction

"" -----------------
"" Buffer operations.
"" -----------------

function! GetBuffersOutput()
    redir => output
    silent execute 'buffers'
    redir END
    return output
endfunction

function! GetListedBuffer()
    let result = []
    for cursor in split(GetBuffersOutput(), '\n')
        let result += [matchstr(TrimLeft(cursor), '^[0-9]*')]
    endfor
    " return a string list.
    return result
endfunction

"" ---------------------------
"" Quickfix Buffer operations.
"" ---------------------------

function! FindQuickfixBufferNumber()
    let result = []
    for cursor in split(GetBuffersOutput(), '\n')
        " Quickfix list name is '[Quickfix list]'
        if match(tolower(cursor), 'quickfix list') != -1
            return str2nr(matchstr(TrimLeft(cursor), '^[0-9]*'))
        endif
    endfor
    return -1
endfunction

function! FindQuickfixBufferIndex(list)
    let quickfix_number = FindQuickfixBufferNumber()
    if quickfix_number == -1
        return -1
    endif

    let find_index = 0
    for cursor in a:list
        if cursor == quickfix_number
            return find_index
        endif
        let find_index += 1
    endfor

    return -1
endfunction

function! RemoveQuickfixBuffer(list)
    let quickfix_index = FindQuickfixBufferIndex(a:list)
    if quickfix_index != -1
        call remove(a:list, quickfix_index)
    endif
    return a:list
endfunction

"" -----------------------
"" Move Buffer operations.
"" -----------------------

function! MoveListedBuffer(offset)
    let buffers = RemoveQuickfixBuffer(GetListedBuffer())
    let size = len(buffers)
    let current = bufnr('%')

    if size < 2
        return
    endif

    " Switching another buffer!
    let position = index(buffers, string(current))
    if position == -1
        echom 'Not found index error.'
        return
    endif

    let next = position + a:offset
    if 0 <= next && next < size
        silent execute 'b ' . buffers[next]
    endif
endfunction

function! MovePrevListedBuffer()
    call MoveListedBuffer(-1)
endfunction

function! MoveNextListedBuffer()
    call MoveListedBuffer(1)
endfunction

"" ------------------------
"" Close Buffer operations.
"" ------------------------

function! CloseBufferAndMoveNext()
    let buffers = GetListedBuffer()
    let quickfix_number = FindQuickfixBufferNumber()
    let size = len(buffers)
    let current = bufnr('%')

    if empty(buffers)
        return
    elseif size == 1
        " Listed buffer size is 1.
        silent execute 'bd ' . buffers[0]
        return
    elseif size == 2
        " Listed buffer size is 2.
        if quickfix_number == -1 || quickfix_number == current
            silent execute 'bnext'
            silent execute 'bd ' . current
        else
            silent execute 'bd ' . buffers[1]
            silent execute 'bd ' . buffers[0]
        endif
        return
    endif

    " Listed buffer size is 3 or more.

    if quickfix_number != current
        let buffers = RemoveQuickfixBuffer(buffers)
    endif

    let position = index(buffers, string(current))
    let size = len(buffers)
    let next = 0

    " Calculate next buffer number.
    if position + 1 < size
        let next = buffers[position+1]
    else
        let next = buffers[position-1]
    endif

    " Switching another buffer!
    silent execute 'b ' . next

    " Close buffer!
    silent execute 'bd ' . string(current)
endfunction

