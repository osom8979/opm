let s:plugin_name = 'vimspector'
let s:plugin_homepage = 'https://github.com/puremourning/vimspector'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

function! s:EditVimspectorForDefault()
    silent execute ':edit .vimspector.json'
    if filereadable('.vimspector.json')
        return
    endif

    for content in readfile(g:opm_vim_script_dir . '/template/vimspector/default.vimspector.json')
        call append(line('$'), content)
    endfor
endfunction

" ---------------
" Command mapping
" ---------------

function! OpmEditVimspectorForDefault()
    call s:EditVimspectorForDefault()
endfunction


" vimspector-visual-studio-vscode
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
let g:vimspector_install_gadgets = ['debugpy', 'vscode-cpptools', 'CodeLLDB']

nmap <F5>         <Plug>VimspectorContinue
nmap <S-F5>       <Plug>VimspectorStop
nmap <C-S-F5>     <Plug>VimspectorRestart
nmap <F6>         <Plug>VimspectorPause
nmap <F9>         <Plug>VimspectorToggleBreakpoint
nmap <S-F9>       <Plug>VimspectorAddFunctionBreakpoint
nmap <F10>        <Plug>VimspectorStepOver
nmap <F11>        <Plug>VimspectorStepInto
nmap <S-F11>      <Plug>VimspectorStepOut

nmap <Leader>di <Plug>VimspectorBalloonEval
xmap <Leader>di <Plug>VimspectorBalloonEval

nmap <LocalLeader><F11> <Plug>VimspectorUpFrame
nmap <LocalLeader><F12> <Plug>VimspectorDownFrame

" VimspectorMkSession
" VimspectorLoadSession


" =========================================================================================================================
" |      _Key_      |                _Mapping_                |                         _Function_                        |
" =========================================================================================================================
" | 'F5'            | '<Plug>VimspectorContinue'              | When debugging, continue. Otherwise start debugging.      |
" -------------------------------------------------------------------------------------------------------------------------
" | 'Shift F5'      | '<Plug>VimspectorStop'                  | Stop debugging.                                           |
" -------------------------------------------------------------------------------------------------------------------------
" | 'Ctrl Shift F5' | '<Plug>VimspectorRestart'               | Restart debugging with the same configuration.            |
" -------------------------------------------------------------------------------------------------------------------------
" | 'F6'            | '<Plug>VimspectorPause'                 | Pause debuggee.                                           |
" -------------------------------------------------------------------------------------------------------------------------
" | 'F9'            | '<Plug>VimspectorToggleBreakpoint'      | Toggle line breakpoint on the current line.               |
" -------------------------------------------------------------------------------------------------------------------------
" | 'Shift F9'      | '<Plug>VimspectorAddFunctionBreakpoint' | Add a function breakpoint for the expression under cursor |
" -------------------------------------------------------------------------------------------------------------------------
" | 'F10'           | '<Plug>VimspectorStepOver'              | Step Over                                                 |
" -------------------------------------------------------------------------------------------------------------------------
" | 'F11'           | '<Plug>VimspectorStepInto'              | Step Into                                                 |
" -------------------------------------------------------------------------------------------------------------------------
" | 'Shift F11'     | '<Plug>VimspectorStepOut'               | Step out of current function scope                        |
" -------------------------------------------------------------------------------------------------------------------------

