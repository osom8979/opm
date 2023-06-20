let s:plugin_name = 'vim-godot'
let s:plugin_homepage = 'https://github.com/habamax/vim-godot'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

func! s:FindGodotExecutable()
    if has('unix')
        return $HOME .  '/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64'
    elseif has('win32')
        return ''
    elseif has('win64')
        return ''
    elseif has('win32unit')
        return ''
    elseif has('mac')
        return ''
    else
        return ''
    endif
endfunc

let g:godot_executable = s:FindGodotExecutable()

func! GodotSettings() abort
    " setlocal foldmethod=expr
    setlocal tabstop=4
    setlocal expandtab

    " nnoremap <buffer> <F4> :GodotRunLast<CR>
    nnoremap <buffer> <F5> :GodotRun<CR>
    nnoremap <buffer> <F6> :GodotRunCurrent<CR>
    " nnoremap <buffer> <F7> :GodotRunFZF<CR>
endfunc

augroup godot | au!
    au FileType gdscript call GodotSettings()
augroup end

