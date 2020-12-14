" global macros.

function! RemoveCr()
    silent execute '%s/$//g'
endfunction

function! RemoveTrailingSpace()
    silent execute '%s/\s*$//g'
endfunction

function! RemoveBlankLines()
    silent execute 'g/^\s*$/d'
endfunction

