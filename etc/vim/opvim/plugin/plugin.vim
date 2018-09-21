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

if !exists('g:opvim_quickmenu_id')
    let g:opvim_quickmenu_id = 100
endif

"" -----------------
"" Command & KeyMap.
"" -----------------

command! -nargs=0 -bang OpvimPreview  call opvim#Preview(<bang>0)
command! -nargs=?       OpvimExec     call opvim#Exec(<f-args>)
command! -nargs=?       OpvimMode     call opvim#Mode(<f-args>)
command! -nargs=0       OpvimCMake    call opvim#CMake()
command! -nargs=?       OpvimBuild    call opvim#Build(<f-args>)
command! -nargs=?       OpvimDebug    call opvim#Debug(<f-args>)
command! -nargs=?       OpvimScript   call opvim#Script(<f-args>)

" -----------------
" Update QuickMenu.
" -----------------

noremap <leader>` <ESC>:call quickmenu#toggle(g:opvim_quickmenu_id)<CR>

function! g:ReloadQuickMenu()
    call quickmenu#current(g:opvim_quickmenu_id)
    call quickmenu#reset()
    call quickmenu#header('OPMVIM {%{g:opvim_project_mode}}')
    call quickmenu#append('# COMMAND', '')
    call quickmenu#append('Preview', 'OpvimPreview', 'Preview opvim project')
    call quickmenu#append('CMake', 'OpvimCMake', 'Run cmake')
    call quickmenu#append('Build', 'OpvimBuild', 'Run build')
    call opvim#UpdateQuickMenu()
endfunction
call g:ReloadQuickMenu()

