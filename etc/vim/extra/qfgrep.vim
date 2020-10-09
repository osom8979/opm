" Buffer helper.

" --------------------
" Quick-fix operations
" --------------------

function! s:GetQuickFixText(line)
    return bufname(a:line['bufnr']) . '|' . a:line['lnum'] . '| ' . a:line['text']
endfunction

function! s:QuickFixGrep(pattern)
    let result = []
    for line in getqflist()
        if s:GetQuickFixText(line) =~ a:pattern
            let result += [line]
        endif
    endfor
    call setqflist(result)
endfunction

function! s:QuickFixGrepIgnore(pattern)
    let result = []
    for line in getqflist()
        if s:GetQuickFixText(line) !~ a:pattern
            let result += [line]
        endif
    endfor
    call setqflist(result)
endfunction

function! s:QuickFixGrepCommand(is_bang, pattern)
    if a:is_bang
        call s:QuickFixGrepIgnore(a:pattern)
    else
        call s:QuickFixGrep(a:pattern)
    endif
endfunction

" ---------------
" Command mapping
" ---------------

function! OpmQuickFixGrepCommand(is_bang, pattern)
    call s:QuickFixGrepCommand(a:is_bang, a:pattern)
endfunction

command! -nargs=* -bang OpmGrepQuickFix call OpmQuickFixGrepCommand(<bang>0, <q-args>)

