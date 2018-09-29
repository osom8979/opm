" OPM-VIM PLUGIN AUTOLOAD.

if exists('g:opvim_loaded')
    finish
endif

call opvim#Initialize()

"" ----------------------------
"" Global settings & variables.
"" ----------------------------

let g:opvim_loaded = 1

if !exists('g:opvim_cmake_path')
    if exists('g:opvim_cmake_which') " init from python code.
        let g:opvim_cmake_path = g:opvim_cmake_which
    else
        let g:opvim_cmake_path = 'cmake'
    endif
endif

if !exists('g:opvim_project_json_name')
    let g:opvim_project_json_name = 'opvim.json'
endif

if !exists('g:opvim_default_project_mode')
    let g:opvim_default_project_mode = 'debug'
endif

if !exists('g:opvim_default_build_prefix')
    let g:opvim_default_build_prefix = 'build-'
endif

if !exists('g:opvim_project_mode')
    let g:opvim_project_mode = g:opvim_default_project_mode
endif

if !exists('g:opvim_debugging_preview')
    let g:opvim_debugging_preview = 1
endif

if !exists('g:opvim_debugging_window_height')
    let g:opvim_debugging_window_height = 10
endif

if !exists('g:opvim_quickmenu_id')
    let g:opvim_quickmenu_id = 100
endif

if !exists('g:opvim_quickmenu_mode_id')
    let g:opvim_quickmenu_mode_id = 101
endif

if !exists('g:show_quickfix_if_execute')
    let g:show_quickfix_if_execute = 1
endif

" -----------------
" Update QuickMenu.
" -----------------

noremap <leader>` <ESC>:call quickmenu#toggle(g:opvim_quickmenu_id)<CR>

function! g:OpvimReloadQuickMenu()
    call quickmenu#current(g:opvim_quickmenu_id)
    call quickmenu#reset()
    call quickmenu#header('OPVIM {%{g:opvim_project_mode}}')
    call quickmenu#append('# COMPILE', '')
    call quickmenu#append('CMake', 'OpvimCMake', 'Run cmake')
    call quickmenu#append('Build', 'OpvimBuild', 'Run build')
    call quickmenu#append('Mode', 'OpvimModeMenu', 'Select mode')
    call opvim#UpdateQuickMenu()
    call quickmenu#append('# UTILITY', '')
    call quickmenu#append('Preview', 'OpvimPreview', 'Preview opvim project')
    call quickmenu#append('Reload', 'OpvimReload', 'Reload opvim project')

    call quickmenu#current(g:opvim_quickmenu_mode_id)
    call quickmenu#reset()
    call quickmenu#header('CHANGE OPVIM MODE {%{g:opvim_project_mode}}')
    call quickmenu#append('# MODES', '')
    call opvim#UpdateQuickMenuMode()
endfunction

"" -----------------
"" Command & KeyMap.
"" -----------------

command! -nargs=0 -bang               OpvimPreview  call opvim#Preview(<bang>0)
command! -nargs=? -complete=shellcmd  OpvimExec     call opvim#Exec(<f-args>)
command! -nargs=?                     OpvimMode     call opvim#Mode(<f-args>)
command! -nargs=0                     OpvimModeMenu call quickmenu#bottom(g:opvim_quickmenu_mode_id)
command! -nargs=0                     OpvimCMake    call opvim#CMake()
command! -nargs=?                     OpvimBuild    call opvim#Build(<f-args>)
command! -nargs=?                     OpvimDebug    call opvim#Debug(<f-args>)
command! -nargs=?                     OpvimScript   call opvim#Script(<f-args>)
command! -nargs=0                     OpvimReload   call g:OpvimReloadQuickMenu()

if has('vim_starting')
    augroup OpvimAutoCommands
        autocmd!
        autocmd VimEnter * call g:OpvimReloadQuickMenu()
    augroup END
else
    call g:OpvimReloadQuickMenu()
endif

