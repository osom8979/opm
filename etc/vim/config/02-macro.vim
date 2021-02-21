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

function! s:GetArgumentOrInput(var, prompt, text, completion)
    if strlen(a:var) >= 1
        return a:var
    else
        if strlen(a:completion) >= 1
            return input(a:prompt, a:text, a:completion)
        else
            return input(a:prompt, a:text)
        endif
    endif
endfunction

function! AsyncRunGrep(flags, pattern, file)
    let flags = s:GetArgumentOrInput(a:flags, 'grep flags? ', '-HIn', '')
    let pattern = s:GetArgumentOrInput(a:pattern, 'grep pattern? ', '<cword>', '')
    let file = s:GetArgumentOrInput(a:file, 'grep file? ', '%:p', 'file')
    silent execute ':AsyncRun grep '.flags.' '.pattern.' '.file
    silent execute 'copen'
endfunction

function! AsyncRunGrepRecursiveIgnoreCase()
    call AsyncRunGrep('-HInri', '', '')
endfunction
function! AsyncRunGrepCwordRecursiveIgnoreCase()
    call AsyncRunGrep('-HInri', '<cword>', '')
endfunction
function! AsyncRunGrepCwdRecursiveIgnoreCase()
    call AsyncRunGrep('-HInri', '', '<cwd>')
endfunction
function! AsyncRunGrepCwordCwdRecursiveIgnoreCase()
    call AsyncRunGrep('-HInri', '<cword>', '<cwd>')
endfunction

function! AsyncRunGrepRecursive()
    call AsyncRunGrep('-HInr', '', '')
endfunction
function! AsyncRunGrepCwordRecursive()
    call AsyncRunGrep('-HInr', '<cword>', '')
endfunction
function! AsyncRunGrepCwdRecursive()
    call AsyncRunGrep('-HInr', '', '<cwd>')
endfunction
function! AsyncRunGrepCwordCwdRecursive()
    call AsyncRunGrep('-HInr', '<cword>', '<cwd>')
endfunction

function! AsyncRunGrepCurrentFileIgnoreCase()
    call AsyncRunGrep('-HIni', '', '%:p')
endfunction
function! AsyncRunGrepCwordCurrentFileIgnoreCase()
    call AsyncRunGrep('-HIni', '<cword>', '%:p')
endfunction

function! AsyncRunGrepCurrentFile()
    call AsyncRunGrep('-HIn', '', '%:p')
endfunction
function! AsyncRunGrepCwordCurrentFile()
    call AsyncRunGrep('-HIn', '<cword>', '%:p')
endfunction

