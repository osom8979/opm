"" Macro setting.

function OpmHelp()
    echom "OPM HELP!"
endfunction

function TrimLeft(text)
    return substitute(a:text, '^[ \t]*', '', '')
endfunction

function GetBuffersOutput()
    redir => output
    silent execute 'buffers'
    redir END
    return output
endfunction

function GetListedBuffer()
    let result = []
    for cursor in split(GetBuffersOutput(), '\n')
        let result += [matchstr(TrimLeft(cursor), '^[0-9]*')]
    endfor
    " return a string list.
    return result
endfunction

function CloseBufferAndMoveNext()
    let buffers = GetListedBuffer()
    let size = len(buffers)
    let current = bufnr('%')

    if empty(buffers)
        return
    endif

    if size >= 2
        " Switching another buffer!
        let position = index(buffers, string(current))
        if position == -1
            echom 'Not found index error.'
            return
        endif

        let next = 0
        if position + 1 < size
            let next = buffers[position+1]
        else
            let next = buffers[position-1]
        endif
        silent execute 'b ' . next
    endif

    " Close buffer!
    silent execute 'bd ' . string(current)
endfunction

