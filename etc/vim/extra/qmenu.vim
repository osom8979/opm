
" ----------
" QuickMenu.
" ----------

let g:opm_quickmenu_id = 100
let g:opm_quickmenu_mode_id = 101
let g:opm_build_mode = 'debug'

noremap <leader>` <ESC>:call quickmenu#toggle(g:opm_quickmenu_id)<CR>

function! OpmReloadQuickMenu()
    call quickmenu#current(g:opm_quickmenu_id)
    call quickmenu#reset()
    call quickmenu#header('[[ OPM Quick Menu ]]')

    call quickmenu#append('# Grepping', '')
    call quickmenu#append('grep-cword', ':AsyncRun grep -Iirn <cword> <cwd>', 'grep -Iirn <cword>')

    " call quickmenu#header('OPM {%{opvim#GetMode()}}')
    " call quickmenu#append('# COMPILE', '')
    " call quickmenu#append('Build', 'OpvimBuild', 'Run build')
    " call quickmenu#append('Mode', 'OpvimModeMenu', 'Select mode')
    " call opvim#UpdateQuickMenu()
    " call quickmenu#append('# UTILITY', '')
    " call quickmenu#append('Preview', 'OpvimPreview', 'Preview opvim project')
    " call quickmenu#append('Reload', 'OpvimReload', 'Reload opvim project')
    " call quickmenu#append('Create', 'OpvimCreate', 'Create opvim project')

    " call quickmenu#current(g:opm_quickmenu_mode_id)
    " call quickmenu#reset()
    " call quickmenu#header('CHANGE OPVIM MODE {%{opvim#GetMode()}}')
    " call quickmenu#append('# MODES', '')
    " call opvim#UpdateQuickMenuMode()
endfunction

call OpmReloadQuickMenu()

"" -----------------
"" Command & KeyMap.
"" -----------------

" command! -nargs=0 -bang               OpvimPreview  call opvim#Preview(<bang>0)
" command! -nargs=? -complete=shellcmd  OpvimExec     call opvim#Exec(<f-args>)
" command! -nargs=?                     OpvimMode     call opvim#Mode(<f-args>)
" command! -nargs=0                     OpvimModeMenu call quickmenu#bottom(g:opm_quickmenu_mode_id)
" command! -nargs=0                     OpvimCMake    call opvim#CMake()
" command! -nargs=?                     OpvimBuild    call opvim#Build(<f-args>)
" command! -nargs=?                     OpvimDebug    call opvim#Debug(<f-args>)
" command! -nargs=?                     OpvimScript   call opvim#Script(<f-args>)
" command! -nargs=0                     OpvimReload   call OpmReloadQuickMenu()
" command! -nargs=0                     OpvimCreate   call opvim#CreateProject()
" command! -nargs=0 OpvimDebugDone call opvim#ExitDebug()

