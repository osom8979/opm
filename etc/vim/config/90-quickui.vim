let s:plugin_name = 'vim-quickui'
let s:plugin_homepage = 'https://github.com/skywind3000/vim-quickui'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

" ----------------
" Global variables
" ----------------

if !exists('g:opm_default_quickui_namespace')
    let g:opm_default_quickui_namespace = 'opm'
endif
if !exists('g:opm_default_quickui_toggle_key')
    let g:opm_default_quickui_toggle_key = '<leader>`'
endif

" -------------------------
" OPM quickui configuration
" -------------------------

call quickui#menu#switch(g:opm_default_quickui_namespace)
call quickui#menu#reset()

call quickui#menu#install('&File', [
            \ [ '&New Buffer', ':new' ],
            \ [ '&Vertically New Buffer', ':vnew' ],
            \ [ '--', '' ],
            \ [ 'E&xit', ':qa' ],
            \ ])

call quickui#menu#install('&Edit', [
            \ [ 'Remove carriage return', ':call RemoveCr()' ],
            \ [ 'Remove trailing space', ':call RemoveTrailingSpace()' ],
            \ [ 'Remove blank lines', ':call RemoveBlankLines()' ],
            \ [ '--', '' ],
            \ ])

call quickui#menu#install('&View', [
            \ [ '&HEX mode', ':OpmHexMode' ],
            \ [ '&TEXT mode', ':OpmTextMode' ],
            \ [ '--', '' ],
            \ [ '&Json formatting', ':OpmJsonFormat' ],
            \ ])

call quickui#menu#install('&Find', [
            \ [ '--', '' ],
            \ [ 'grep-ri()', ':call AsyncRunGrepCwordCwdRecursiveIgnoreCase()' ],
            \ [ 'grep-ri(p)', ':call AsyncRunGrepCwdRecursiveIgnoreCase()' ],
            \ [ 'grep-ri(f)', ':call AsyncRunGrepCwordRecursiveIgnoreCase()' ],
            \ [ 'grep-ri(p,f)', ':call AsyncRunGrepRecursiveIgnoreCase()' ],
            \ [ '--', '' ],
            \ [ 'grep-r()', ':call AsyncRunGrepCwordCwdRecursive()' ],
            \ [ 'grep-r(p)', ':call AsyncRunGrepCwdRecursive()' ],
            \ [ 'grep-r(f)', ':call AsyncRunGrepCwordRecursive()' ],
            \ [ 'grep-r(p,f)', ':call AsyncRunGrepRecursive()' ],
            \ [ '--', '' ],
            \ [ 'grep-i()', ':call AsyncRunGrepCwordCurrentFileIgnoreCase()' ],
            \ [ 'grep-i(p)', ':call AsyncRunGrepCurrentFileIgnoreCase()' ],
            \ [ '--', '' ],
            \ [ 'grep()', ':call AsyncRunGrepCwordCurrentFile()' ],
            \ [ 'grep(p)', ':call AsyncRunGrepCurrentFile()' ],
            \ ])

call quickui#menu#install('&Options', [
            \ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!'],
            \ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!'],
            \ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!'],
            \ ])

call quickui#menu#install('H&elp', [
            \ ['Vim &Cheatsheet', 'help index'],
            \ ['Vim T&ips', 'help tips'],
            \ ['Vim &Tutorial', 'help tutor'],
            \ ['Vim &Quick Reference', 'help quickref'],
            \ ['--', ''],
            \ ['&Loaded Scripts', ':OpmLoadedScripts'],
            \ ['--', ''],
            \ ['&Reload', ':OpmReload'],
            \ ], 10000)

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" -----------
" Key mapping
" -----------

silent execute 'noremap '.g:opm_default_quickui_toggle_key.' <ESC>:call quickui#menu#open(g:opm_default_quickui_namespace)<CR>'
