" OPM-VIM PLUGIN AUTOLOAD.

if exists('g:opvim_loaded')
    finish
endif

call opvim#Initialize()

"" ----------------------------
"" Global settings & variables.
"" ----------------------------

let g:opvim_loaded = 1

if !exists('g:opvim_developer_debug')
    let g:opvim_developer_debug = 1
endif

"" -----------------
"" Global functions.
"" -----------------

function! g:OpvimReload()
    " ...
endfunction

if has('vim_starting')
    augroup OpvimAutoCommands
        autocmd!
        autocmd VimEnter * call g:OpvimReload()
    augroup END
else
    call g:OpvimReload()
endif

