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

let s:request_prompt = "Do you have any additional requests?"

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

    " Copy to Unnamed Register
    let @" = join(l:output, "\n")
endfunction

function! PostProcessClaudeCodeOutputWithDefault()
    call PostProcessClaudeCodeOutput(g:claude_target_filepath, g:claude_target_linenum)
endfunction

function! AsyncRunClaudeCodeAutocomplete(filepath, linenum)
    let l:prompt = s:autocomplete_prompt
    let l:prompt = substitute(l:prompt, '{F}', a:filepath, 'g')
    let l:prompt = substitute(l:prompt, '{N}', a:linenum, 'g')

    " let l:request = input(s:request_prompt)
    " if 1 <= strlen(l:request)
    "     let l:prompt = l:prompt . "\n" . string(l:request)
    " endif

    let g:claude_target_filepath = a:filepath
    let g:claude_target_linenum = a:linenum

    " let l:post = 'call PostProcessClaudeCodeOutput('.string(a:filepath).','.a:linenum.')'
    let l:post = 'call PostProcessClaudeCodeOutputWithDefault()'
    let l:command = 'opn-claude -p ' . string(l:prompt)

    silent call asyncrun#run('!', {'post': l:post}, l:command)
    silent call OpmOpenQuickfixBuffer()
endfunction

function! AsyncRunClaudeCodeAutocompleteWithCursor()
    call AsyncRunClaudeCodeAutocomplete(expand('%:p'), line('.'))
endfunction

function! s:GetVisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]

    if (line2byte(line_start) + column_start) > (line2byte(line_end) + column_end)
        let [line_start, column_start, line_end, column_end] = [line_end, column_end, line_start, column_start]
    endif

    let lines = getline(line_start, line_end)

    if empty(lines)
        return ''
    endif

    let lines[-1] = lines[-1][: column_end - (&selection ==# 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]

    return join(lines, "\n")
endfunction

function! AsyncRunClaudeCodeKoreanToEnglish()
    let l:selected_text = s:GetVisualSelection()

    if empty(l:selected_text)
        echom 'No text selected'
        return
    endif

    let l:prompt = 'Translate the following Korean text to English: ' . l:selected_text
    let l:command = 'opn-claude -p ' . string(l:prompt)

    silent call asyncrun#run('!', {}, l:command)
    silent call OpmOpenQuickfixBuffer()
endfunction

" ---------------
" Command mapping
" ---------------

command! OpmAsyncRunClaudeCodeAutocomplete execute 'call AsyncRunClaudeCodeAutocompleteWithCursor()'
command! OpmAsyncRunClaudeCodeKoreanToEnglish execute 'call AsyncRunClaudeCodeKoreanToEnglish()'

" ----------------
" Keyboard mapping
" ----------------

noremap <leader><Space> <ESC>:OpmAsyncRunClaudeCodeAutocomplete<CR>

