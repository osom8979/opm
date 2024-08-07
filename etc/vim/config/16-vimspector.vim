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

let g:vimspector_enable_mappings = 'opvim'

" vscode-cpptools requires mono-core
let g:vimspector_install_gadgets = [
            \ 'CodeLLDB',
            \ 'debugpy',
            \ 'delve',
            \ 'vscode-node-debug2',
            \ 'debugger-for-chrome',
            \ 'vscode-firefox-debug',
            \ ]

if g:vimspector_enable_mappings ==# 'opvim'
    nmap <S-F9>     <Plug>VimspectorLaunch
    nmap <F33>      <Plug>VimspectorLaunch

    nmap <C-F2>     <Plug>VimspectorStop

    nmap <F9>       <Plug>VimspectorContinue
    nmap <F7>       <Plug>VimspectorStepInto
    nmap <F8>       <Plug>VimspectorStepOver

    nmap <S-F8>     <Plug>VimspectorStepOut
    nmap <F20>      <Plug>VimspectorStepOut

    nmap <C-F8>     <Plug>VimspectorToggleBreakpoint
    nmap <F32>      <Plug>VimspectorToggleBreakpoint

    nmap <leader>di <Plug>VimspectorBalloonEval
    xmap <leader>di <Plug>VimspectorBalloonEval

    nmap <C-F11>    <Plug>VimspectorUpFrame
    nmap <F35>      <Plug>VimspectorUpFrame

    nmap <C-F12>    <Plug>VimspectorDownFrame
    nmap <F36>      <Plug>VimspectorDownFrame
endif

" VimspectorMkSession
" VimspectorLoadSession

