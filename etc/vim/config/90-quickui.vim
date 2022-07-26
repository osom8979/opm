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

call quickui#menu#install("&File", [
            \ [ "New &Horizontally Buffer\t:new", ":new", "Create a new window and start editing an empty file in it." ],
            \ [ "New &Vertically Buffer\t:vnew", ":vnew", "Create a new window and start editing an empty file in it. but split vertically." ],
            \ [ "--", "" ],
            \ [ "Edit .tasks", ":call OpmEditTasksForDefault()" ],
            \ [ "Edit .vimspector.json", ":call OpmEditVimspectorForDefault()" ],
            \ [ "--", "" ],
            \ [ "E&xit\t:qa", ":qa", "Exit Vim, unless there are some buffers which have been changed." ],
            \ [ "Exit Force\t:qa!", ":qa", "Exit Vim. Any changes to buffers are lost." ],
            \ ])

call quickui#menu#install("&Edit", [
            \ [ "Remove &carriage return", ":call RemoveCr()" ],
            \ [ "Remove &trailing space", ":call RemoveTrailingSpace()" ],
            \ [ "Remove &blank lines", ":call RemoveBlankLines()" ],
            \ [ "--", "" ],
            \ ])

call quickui#menu#install("&Grep", [
            \ [ "Recursive Ignore (<cword>,<cwd>)", ":call AsyncRunGrepCwordCwdRecursiveIgnoreCase()" ],
            \ [ "Recursive Ignore (pattern,<cwd>)", ":call AsyncRunGrepCwdRecursiveIgnoreCase()" ],
            \ [ "Recursive Ignore (<cword>,file)", ":call AsyncRunGrepCwordRecursiveIgnoreCase()" ],
            \ [ "Recursive Ignore (pattern,file)", ":call AsyncRunGrepRecursiveIgnoreCase()" ],
            \ [ "--", "" ],
            \ [ "Recursive (<cword>,<cwd>)", ":call AsyncRunGrepCwordCwdRecursive()" ],
            \ [ "Recursive (pattern,<cwd>)", ":call AsyncRunGrepCwdRecursive()" ],
            \ [ "Recursive (<cword>,file)", ":call AsyncRunGrepCwordRecursive()" ],
            \ [ "Recursive (pattern,file)", ":call AsyncRunGrepRecursive()" ],
            \ [ "--", "" ],
            \ [ "Ignore (<cword>)", ":call AsyncRunGrepCwordCurrentFileIgnoreCase()" ],
            \ [ "Ignore (pattern)", ":call AsyncRunGrepCurrentFileIgnoreCase()" ],
            \ [ "--", "" ],
            \ [ "Normal (<cword>)", ":call AsyncRunGrepCwordCurrentFile()" ],
            \ [ "Normal (pattern)", ":call AsyncRunGrepCurrentFile()" ],
            \ ])

call quickui#menu#install("&Code", [
            \ [ "&HEX mode", ":OpmHexMode" ],
            \ [ "&TEXT mode", ":OpmTextMode" ],
            \ [ "--", "" ],
            \ [ "&Json formatting", ":OpmJsonFormat" ],
            \ ])

call quickui#menu#install("&Navigation", [
            \ [ "GoTo &definition\tgd", ':execute "normal \<Plug>(coc-definition)"' ],
            \ [ "GoTo &references\tgr", ':execute "normal \<Plug>(coc-references)"' ],
            \ [ "GoTo &type\tgy", ':execute "normal \<Plug>(coc-type-definition)"' ],
            \ [ "GoTo &implementation\tgi", ':execute "normal \<Plug>(coc-implementation)"' ],
            \ [ "--", "" ],
            \ [ "Diagnostic &prev\t[g", ':execute "normal \<Plug>(coc-diagnostic-prev)"' ],
            \ [ "Diagnostic &next\t]g", ':execute "normal \<Plug>(coc-diagnostic-next)"' ],
            \ [ "--", "" ],
            \ ])

call quickui#menu#install("&Debug", [
            \ [ "&Launch\tS-F9", ':execute "normal \<Plug>VimspectorLaunch"' ],
            \ [ "--", "" ],
            \ [ "&Continue\tF9", ':execute "normal \<Plug>VimspectorContinue"' ],
            \ [ "&Stop", ':execute "normal \<Plug>VimspectorStop"' ],
            \ [ "&Restart", ':execute "normal \<Plug>VimspectorRestart"' ],
            \ [ "&Pause", ':execute "normal \<Plug>VimspectorPause"' ],
            \ [ "--", "" ],
            \ [ "Toggle &Breakpoint\tC-F8", ':execute "normal \<Plug>VimspectorToggleBreakpoint"' ],
            \ [ "Toggle Conditional Breakpoint", ':execute "normal \<Plug>VimspectorToggleConditionalBreakpoint"' ],
            \ [ "--", "" ],
            \ [ "Step &Into\tF7", ':execute "normal \<Plug>VimspectorStepInto"' ],
            \ [ "Step Over (&Next)\tF8", ':execute "normal \<Plug>VimspectorStepOver"' ],
            \ [ "Step &Out\tS-F8", ':execute "normal \<Plug>VimspectorStepOut"' ],
            \ [ "--", "" ],
            \ [ "Frame &Up\tC-F11", ':execute "normal \<Plug>VimspectorUpFrame"' ],
            \ [ "Frame &Down\tC-F12", ':execute "normal \<Plug>VimspectorDownFrame"' ],
            \ [ "--", "" ],
            \ [ "Balloon &Eval", ':execute "normal \<Plug>VimspectorBalloonEval"' ],
            \ [ "--", "" ],
            \ [ "Install Gadgets", ':VimspectorInstall' ],
            \ [ "Update Gadgets", ':VimspectorUpdate' ],
            \ ])

call quickui#menu#install("&View", [
            \ [ "&NERDTree\t\\\\1", ":NERDTreeToggle" ],
            \ [ "&Quickfix\t\\\\3", ":call OpmToggleQuickfixBuffer()" ],
            \ [ "&Terminal\t\\\\4", ":call OpmToggleTerminalBuffer()" ],
            \ ])

call quickui#menu#install("&Options", [
            \ ['Set &Spell (%{&spell? "Off":"On"})', 'set spell!'],
            \ ['Set Scroll&bind (%{&scrollbind? "Off":"On"})', 'set scrollbind!'],
            \ ['Set &Cursor Line (%{&cursorline? "Off":"On"})', 'set cursorline!'],
            \ ['Set &Paste (%{&paste? "Off":"On"})', 'set paste!'],
            \ ['Set &Wrap (%{&wrap? "Off":"On"})', 'set wrap!'],
            \ ])

call quickui#menu#install("&Info", [
            \ [ "Print file path (relative)", ":echo @%" ],
            \ [ "Print file path (absolute)", ":echo expand('%:p')" ],
            \ [ "--", "" ],
            \ ])

call quickui#menu#install("H&elp", [
            \ ["Vim &Cheatsheet", "help index"],
            \ ["Vim T&ips", "help tips"],
            \ ["Vim &Tutorial", "help tutor"],
            \ ["Vim &Quick Reference", "help quickref"],
            \ ["--", ""],
            \ ["&Loaded Scripts", ":OpmLoadedScripts"],
            \ ["Healthcheck", ":checkhealth"],
            \ ["--", ""],
            \ ["&Reload", ":OpmReload"],
            \ ], 10000)

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" -----------
" Key mapping
" -----------

silent execute 'noremap '.g:opm_default_quickui_toggle_key.' <ESC>:call quickui#menu#open(g:opm_default_quickui_namespace)<CR>'

