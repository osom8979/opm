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

let s:opm_vim_template_dir = g:opm_vim_script_dir . '/template/'

function! CreateNewFileAsTemplate(file, template)
    silent execute ':edit ' . a:file
    if filereadable(a:file)
        return
    endif

    let cursor = line('.')
    for content in readfile(a:template)
        call append(cursor, content)
        let cursor = line('$')
    endfor
endfunction

function! s:TemplateMenus()
    let result = []
    let expr = fnameescape(g:opm_vim_script_dir) . '/template/{,.}*'
    for dir in glob(expr, v:true, v:true)
        if !isdirectory(dir)
            continue
        endif

        let dirname = fnamemodify(dir, ':h:t')
        if dirname == '.' || dirname == '..'
            continue
        endif

        let templateExpr = fnameescape(dir) . '{,.}*'
        for template in glob(templateExpr, v:true, v:true)
            if isdirectory(template)
                continue
            endif

            let filename = fnamemodify(template, ':t')
            let menuName = 'Edit '.dirname.' < '.filename
            let menuCmd = ':call CreateNewFileAsTemplate("'.dirname.'","'.template.'")'
            let result += [[menuName, menuCmd]]
        endfor
        let result += [['--', '']]
    endfor
    return result
endfunction

" -------------------------
" OPM quickui configuration
" -------------------------

call quickui#menu#switch(g:opm_default_quickui_namespace)
call quickui#menu#reset()

call quickui#menu#install("&File", [
            \ [ "New &Horizontally Buffer\t:new", ":new", "Create a new window and start editing an empty file in it." ],
            \ [ "New &Vertically Buffer\t:vnew", ":vnew", "Create a new window and start editing an empty file in it. but split vertically." ],
            \ [ "--", "" ],
            \ [ "E&xit\t:qa", ":qa", "Exit Vim, unless there are some buffers which have been changed." ],
            \ [ "Exit Force\t:qa!", ":qa", "Exit Vim. Any changes to buffers are lost." ],
            \ ])

call quickui#menu#install("&Template", s:TemplateMenus())

call quickui#menu#install("&Edit", [
            \ [ "Remove &carriage return", ":call RemoveCr()" ],
            \ [ "Remove &trailing space", ":call RemoveTrailingSpace()" ],
            \ [ "Remove &blank lines", ":call RemoveBlankLines()" ],
            \ [ "--", "" ],
            \ [ "HEX color to rgba", ":HexRgba" ],
            \ [ "--", "" ],
            \ [ "&HEX mode", ":OpmHexMode" ],
            \ [ "&TEXT mode", ":OpmTextMode" ],
            \ [ "--", "" ],
            \ [ "&Json formatting", ":OpmJsonFormat" ],
            \ ])

call quickui#menu#install("&Grep", [
            \ [ "File (<cword>)", ":call AsyncRunGrepCwordCurrentFile()" ],
            \ [ "File (pattern)", ":call AsyncRunGrepCurrentFile()" ],
            \ [ "--", "" ],
            \ [ "File IC (<cword>)", ":call AsyncRunGrepCwordCurrentFileIgnoreCase()" ],
            \ [ "File IC (pattern)", ":call AsyncRunGrepCurrentFileIgnoreCase()" ],
            \ [ "--", "" ],
            \ [ "Project (<cword>,<cwd>)", ":call AsyncRunGrepCwordCwdRecursive()" ],
            \ [ "Project (pattern,<cwd>)", ":call AsyncRunGrepCwdRecursive()" ],
            \ [ "Project (<cword>,file)", ":call AsyncRunGrepCwordRecursive()" ],
            \ [ "Project (pattern,file)", ":call AsyncRunGrepRecursive()" ],
            \ [ "--", "" ],
            \ [ "Project IC (<cword>,<cwd>)", ":call AsyncRunGrepCwordCwdRecursiveIgnoreCase()" ],
            \ [ "Project IC (pattern,<cwd>)", ":call AsyncRunGrepCwdRecursiveIgnoreCase()" ],
            \ [ "Project IC (<cword>,file)", ":call AsyncRunGrepCwordRecursiveIgnoreCase()" ],
            \ [ "Project IC (pattern,file)", ":call AsyncRunGrepRecursiveIgnoreCase()" ],
            \ ])

call quickui#menu#install("&Coc", [
            \ [ "&Find references", ':execute "normal \<Plug>(coc-references)"' ],
            \ [ "--", "" ],
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
            \ [ "Reset", ':VimspectorReset' ],
            \ [ "--", "" ],
            \ [ "&Continue\tF9", ':execute "normal \<Plug>VimspectorContinue"' ],
            \ [ "&Stop", ':execute "normal \<Plug>VimspectorStop"' ],
            \ [ "&Restart", ':execute "normal \<Plug>VimspectorRestart"' ],
            \ [ "&Pause", ':execute "normal \<Plug>VimspectorPause"' ],
            \ [ "--", "" ],
            \ [ "Breakpoints", ':VimspectorBreakpoints' ],
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
            \ [ "E&xchange Next Window\t<C-w>x", ':call feedkeys("\<C-w>x")' ],
            \ [ "--", "" ],
            \ [ "&NERDTree\t\\\\1", ":NERDTreeToggle" ],
            \ [ "T&agbar\t\\\\2", ":Tagbar" ],
            \ [ "&Quickfix\t\\\\3", ":call OpmToggleQuickfixBuffer()" ],
            \ [ "&Terminal\t\\\\4", ":call OpmToggleTerminalBuffer()" ],
            \ [ "&Gundo\t\\\\5", ":GundoToggle" ],
            \ ])

call quickui#menu#install("&Options", [
            \ ['Set &Spell (%{&spell? "Off":"On"})', 'set spell!'],
            \ ['Set Scroll&bind (%{&scrollbind? "Off":"On"})', 'set scrollbind!'],
            \ ['Set &Cursor Line (%{&cursorline? "Off":"On"})', 'set cursorline!'],
            \ ['Set &Paste (%{&paste? "Off":"On"})', 'set paste!'],
            \ ['Set &Wrap (%{&wrap? "Off":"On"})', 'set wrap!'],
            \ ])

call quickui#menu#install("&Help", [
            \ ["Vim &Cheatsheet", "help index"],
            \ ["Vim T&ips", "help tips"],
            \ ["Vim &Tutorial", "help tutor"],
            \ ["Vim &Quick Reference", "help quickref"],
            \ ["Vim Config", "help config"],
            \ ["--", ""],
            \ [ "Print file path (relative)", ":echo @%" ],
            \ [ "Print file path (absolute)", ":echo expand('%:p')" ],
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

