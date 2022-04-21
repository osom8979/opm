" Debugging helper.

" ----------------
" Global variables
" ----------------

if !exists('g:opm_debug_toggle_break_key')
    let g:opm_debug_toggle_break_key = '<F9>'
endif
if !exists('g:opm_debug_step_into_key')
    let g:opm_debug_step_into_key = '<F11>'
endif
if !exists('g:opm_debug_step_over_key')
    let g:opm_debug_step_over_key = '<F10>'
endif
if !exists('g:opm_debug_finish_key')
    let g:opm_debug_finish_key = '<leader><F11>'
endif
if !exists('g:opm_debug_continue_key')
    let g:opm_debug_continue_key = '<F12>'
endif

" --------
" Features
" --------

let s:break        = 'break'
let s:clear        = 'clear'
let s:toggle_break = 'toggle_break'
let s:step_into    = 'step'
let s:step_over    = 'next'
let s:finish       = 'finish'
let s:continue     = 'continue'

let s:termdebug = {}
let s:termdebug[s:break]        = ':Break'
let s:termdebug[s:clear]        = ':Clear'
let s:termdebug[s:toggle_break] = ''
let s:termdebug[s:step_into]    = ':Step'
let s:termdebug[s:step_over]    = ':Over'
let s:termdebug[s:finish]       = ':Finish'
let s:termdebug[s:continue]     = ':Continue'

let s:termdbg = {}
let s:termdbg[s:break]        = ''
let s:termdbg[s:clear]        = ''
let s:termdbg[s:toggle_break] = ':TToggleBreak'
let s:termdbg[s:step_into]    = ':TStep'
let s:termdbg[s:step_over]    = ':TNext'
let s:termdbg[s:finish]       = ':TFinish'
let s:termdbg[s:continue]     = ':TContinue'

" --------------------
" Debugging operations
" --------------------

function! s:RunExistCommand(...)
    for cmd in a:000
        if strlen(cmd) >= 1 && exists(cmd) == 2
            execute cmd
            return
        endif
    endfor
endfunction

function! s:RunCommand(cmd)
    call s:RunExistCommand(s:termdbg[a:cmd], s:termdebug[a:cmd])
endfunction

function! s:ToggleBreak()
    call s:RunCommand(s:toggle_break)
endfunction

function! s:StepInto()
    call s:RunCommand(s:step_into)
endfunction

function! s:StepOver()
    call s:RunCommand(s:step_over)
endfunction

function! s:Finish()
    call s:RunCommand(s:finish)
endfunction

function! s:Continue()
    call s:RunCommand(s:continue)
endfunction

" -----------
" Key mapping
" -----------

function! OpmDebugToggleBreak()
    call s:ToggleBreak()
endfunction

function! OpmDebugStepInto()
    call s:StepInto()
endfunction

function! OpmDebugStepOver()
    call s:StepOver()
endfunction

function! OpmDebugFinish()
    call s:Finish()
endfunction

function! OpmDebugContinue()
    call s:Continue()
endfunction

" silent execute 'noremap '.g:opm_debug_step_into_key.' <ESC>:call OpmDebugStepInto()<CR>'
" silent execute 'noremap '.g:opm_debug_step_over_key.' <ESC>:call OpmDebugStepOver()<CR>'
" silent execute 'noremap '.g:opm_debug_finish_key   .' <ESC>:call OpmDebugFinish()<CR>'

