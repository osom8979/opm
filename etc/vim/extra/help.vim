" Prints a help message.

function! s:PrintHelpMessage()
    let lines = readfile(g:opm_vim_script_dir . '/doc/help.txt')
    for line in lines
        echo line
    endfor
endfunction

" ---------------
" Command mapping
" ---------------

function! OpmPrintHelp()
    call s:PrintHelpMessage()
endfunction

command! OpmHelp execute ':call OpmPrintHelp()'

