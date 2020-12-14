let s:plugin_name = 'quickmenu.vim'
let s:plugin_homepage = 'https://github.com/skywind3000/quickmenu.vim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let g:quickmenu_max_width = 40
let g:quickmenu_disable_nofile = 1
let g:quickmenu_ft_blacklist = ['netrw', 'nerdtree', 'startify']
let g:quickmenu_padding_left = 3
let g:quickmenu_padding_right = 3

" QuickMenu
" L: enable cursorline
" H: cmdline help
let g:quickmenu_options = "LH"

" ----------------
" Global variables
" ----------------

if !exists('g:opm_default_quickmenu_id')
    let g:opm_default_quickmenu_id = 1
endif
if !exists('g:opm_default_quickmenu_toggle_key')
    let g:opm_default_quickmenu_toggle_key = '<leader>`'
endif

" ---------------------------
" OPM quickmenu configuration
" ---------------------------

function! s:UpdateDefaultOpmQuickMenu()
    call quickmenu#current(g:opm_default_quickmenu_id)
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
call s:UpdateDefaultOpmQuickMenu()

" -----------
" Key mapping
" -----------

silent execute 'noremap '.g:opm_default_quickmenu_toggle_key.' <ESC>:call quickmenu#toggle(g:opm_default_quickmenu_id)<CR>'

