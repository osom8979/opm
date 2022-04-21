let s:plugin_name = 'vimspector'
let s:plugin_homepage = 'https://github.com/puremourning/vimspector'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

" vimspector-visual-studio-vscode
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'

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

