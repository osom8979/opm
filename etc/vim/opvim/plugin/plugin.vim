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

if !exists('g:opvim_asyncrun_enable')
    if exists('g:asyncrun_support')
        let g:opvim_asyncrun_enable = 1
    else
        let g:opvim_asyncrun_enable = 0
    endif
endif

if !exists('g:opvim_debugging')
    let g:opvim_debugging = 0
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

" QuickMenu
noremap <leader>` :call quickmenu#toggle(0)<CR>

