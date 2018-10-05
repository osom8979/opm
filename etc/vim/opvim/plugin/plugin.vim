" OPM-VIM PLUGIN AUTOLOAD.

if exists('g:opvim_loaded')
    finish
endif

call opvim#Initialize()

"" ----------------------------
"" Global settings & variables.
"" ----------------------------

let g:opvim_loaded = 1

" [[ CMAKE ]]

if !exists('g:opvim_cmake_path')
    if exists('g:opvim_cmake_which') " init from python code.
        let g:opvim_cmake_path = g:opvim_cmake_which
    else
        let g:opvim_cmake_path = 'cmake'
    endif
endif

" [[ PROJECT ]]

if !exists('g:opvim_project_json_name')
    let g:opvim_project_json_name = 'opvim.json'
endif

if !exists('g:opvim_project_setting_dir_name')
    let g:opvim_project_setting_dir_name = '.opvim'
endif

if !exists('g:opvim_default_build_prefix')
    let g:opvim_default_build_prefix = 'build-'
endif

if !exists('g:opvim_project_cache_json_name')
    let g:opvim_project_cache_json_name = 'opvim.cache.json'
endif


" [[ DEVELOPER ]]

if !exists('g:opvim_developer_debug')
    let g:opvim_developer_debug = 1
endif

" [[ QUICK-FIX ]]

if !exists('g:show_quickfix_if_execute')
    let g:show_quickfix_if_execute = 1
endif

" [[ DEBUGGING ]]

if !exists('g:opvim_debugging_window_height')
    let g:opvim_debugging_window_height = 10
endif

if !exists('g:opvim_debugging_script_name')
    let g:opvim_debugging_script_name = 'debugging-init.py'
endif

if !exists('g:opvim_debugging_fifo_name')
    let g:opvim_debugging_fifo_name = 'debugging.fifo'
endif

" Debugging cache (Don't change this variables)
let g:opvim_debugging_fifo_server_id = 0

" [[ QUICK-MENU ]]

if !exists('g:opvim_quickmenu_id')
    let g:opvim_quickmenu_id = 100
endif

if !exists('g:opvim_quickmenu_mode_id')
    let g:opvim_quickmenu_mode_id = 101
endif

" -----------------
" Update QuickMenu.
" -----------------

noremap <leader>` <ESC>:call quickmenu#toggle(g:opvim_quickmenu_id)<CR>

function! g:OpvimReloadQuickMenu()
    call quickmenu#current(g:opvim_quickmenu_id)
    call quickmenu#reset()
    call quickmenu#header('OPVIM {%{opvim#GetMode()}}')
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
    call quickmenu#header('CHANGE OPVIM MODE {%{opvim#GetMode()}}')
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

command! -nargs=0 OpvimDebugDone call opvim#ExitDebug()

if has('vim_starting')
    augroup OpvimAutoCommands
        autocmd!
        autocmd VimEnter * call g:OpvimReloadQuickMenu()
    augroup END
else
    call g:OpvimReloadQuickMenu()
endif

