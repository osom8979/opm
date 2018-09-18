" OPM-VIM PLUGIN AUTOLOAD.

if exists('g:opvim_loaded')
    finish
endif

let g:opvim_loaded = 1
call opvim#Initialize()

"" ----------------------------
"" Global settings & variables.
"" ----------------------------

if !exists('g:opvim_cmake_path')
    if exists('g:opvim_cmake_which')
        let g:opvim_cmake_path = g:opvim_cmake_which
    else
        let g:opvim_cmake_path = 'cmake'
    endif
endif

if !exists('g:opvim_project_name')
    let g:opvim_project_name = 'opvim.json'
endif

if !exists('g:opvim_project_mode')
    let g:opvim_project_mode = 'debug'
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

command! -nargs=? OpvimExec     call opvim#Exec(<f-args>)
command! -nargs=? OpvimCMake    call opvim#CMake(<f-args>)
command! -nargs=? OpvimBuild    call opvim#Build(<f-args>)
command! -nargs=? OpvimDebug    call opvim#Debug(<f-args>)
command! -nargs=? OpvimTest     call opvim#Test(<f-args>)
command! -nargs=? OpvimOpen     call opvim#Open(<f-args>)
command! -nargs=? OpvimMode     call opvim#Mode(<f-args>)
command! -nargs=0 OpvimPreview  call opvim#Preview()

nnoremap <leader><leader><leader>c  :OpvimCMake<CR>
nnoremap <leader><leader><leader>b  :OpvimBuild<CR>
nnoremap <leader><leader><leader>d  :OpvimDebug<CR>
nnoremap <leader><leader><leader>t  :OpvimTest<CR>
nnoremap <leader><leader><leader>o  :OpvimOpen<CR>
nnoremap <leader><leader><leader>m  :OpvimMode<CR>
nnoremap <leader><leader><leader>p  :OpvimPreview<CR>

