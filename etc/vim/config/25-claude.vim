" Claude Code Helper

let g:claude_target_filepath = ''
let g:claude_target_linenum = -1

let s:autocomplete_prompt_lines = [
    \ "Suggest code to add at line {N} of {F}. Requirements:",
    \ "- Code must be in English.",
    \ "- Add a Korean comment below explaining why this addition is needed.",
    \ "- Do not apply any formatting such as Markdown or code blocks.",
    \ "- Output only the code and code's comment, nothing else."
    \ ]
let s:autocomplete_prompt = join(s:autocomplete_prompt_lines, "\n")

function! PostProcessClaudeCodeOutput(filepath, linenum)
    if g:asyncrun_code != 0
        echom 'Claude command failed with code: ' . g:asyncrun_code
        return
    endif

    let l:qflist = getqflist()
    let l:output = []

    for item in l:qflist
        if !empty(item.text)
            call add(l:output, item.text)
        endif
    endfor

    " Trim the first and last lines.
    " - First line: '[opn-claude -p ...]'
    " - Last line: '[Finished in N seconds]'
    if 2 < len(l:output)
        let l:output = l:output[1:-2]
    endif

    let @" = join(l:output, "\n")
endfunction

function! AsyncRunClaudeCodeAutocomplete(filepath, linenum)
    let l:prompt = s:autocomplete_prompt
    let l:prompt = substitute(l:prompt, '{F}', a:filepath, 'g')
    let l:prompt = substitute(l:prompt, '{N}', a:linenum, 'g')

    let g:claude_target_filepath = a:filepath
    let g:claude_target_linenum = a:linenum

    " let l:post = 'call PostProcessClaudeCodeOutput('.string(a:filepath).','.a:linenum.')'
    let l:post = 'call PostProcessClaudeCodeOutput(g:claude_target_filepath, g:claude_target_linenum)'
    let l:command = 'opn-claude -p "'.l:prompt.'"'

    silent call asyncrun#run('!', {'post': l:post}, l:command)
    silent call OpmOpenQuickfixBuffer()
endfunction

function! AsyncRunClaudeCodeAutocompleteWithCursor()
    call AsyncRunClaudeCodeAutocomplete(expand('%:p'), line('.'))
endfunction

" ---------------
" Command mapping
" ---------------

command! OpmAsyncRunClaudeCodeAutocomplete execute 'call AsyncRunClaudeCodeAutocompleteWithCursor()'

" ----------------
" Keyboard mapping
" ----------------

noremap <leader><Space> <ESC>:OpmAsyncRunClaudeCodeAutocomplete<CR>

