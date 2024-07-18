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

function! s:TemplateMenuNode(dir_path, node_path)
    let result = []

    let normal_nodes = globpath(a:dir_path, '*', 0, 1)
    let hidden_nodes = globpath(a:dir_path, '.[^.]*', 0, 1)
    let nodes = normal_nodes + hidden_nodes

    for node in nodes
        let node_name = fnamemodify(node, ':t')
        if node_name == '.' || node_name == '..'
            continue
        endif

        if isdirectory(node)
            let subnode_path = a:node_path == '' ? node_name : a:node_path.'/'.node_name
            let result += s:TemplateMenuNode(node, subnode_path)
            continue
        endif

        let menu_name = 'Edit '.a:node_path.' ← '.node_name
        let menu_cmd = ':call CreateNewFileAsTemplate("'.a:node_path.'","'.node.'")'
        let result += [[menu_name, menu_cmd]]
    endfor
    return result
endfunction

function! s:TemplateMenus()
    let template_dir = fnameescape(g:opm_vim_script_dir) . '/template'
    return s:TemplateMenuNode(template_dir, '')
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
            \ ] + s:TemplateMenus() + [
            \ [ "--", "" ],
            \ [ "E&xit\t:qa", ":qa", "Exit Vim, unless there are some buffers which have been changed." ],
            \ [ "Exit Force\t:qa!", ":qa", "Exit Vim. Any changes to buffers are lost." ],
            \ ])

call quickui#menu#install("&Edit", [
            \ [ "Remove &carriage return", ":call RemoveCr()" ],
            \ [ "Remove &trailing space", ":call RemoveTrailingSpace()" ],
            \ [ "Remove &blank lines", ":call RemoveBlankLines()" ],
            \ [ "--", "" ],
            \ [ "&Json formatting", ":OpmJsonFormat" ],
            \ [ "&XML formatting", ":OpmXmlFormat" ],
            \ [ "--", "" ],
            \ [ "&HEX mode", ":OpmHexMode" ],
            \ [ "&TEXT mode", ":OpmTextMode" ],
            \ [ "--", "" ],
            \ [ "HEX color to rgba", ":HexRgba" ],
            \ [ "--", "" ],
            \ [ "Wiki/4Space to Asterisk", ":%s/^    /* / | %s/    /*/g" ],
            \ [ "--", "" ],
            \ [ "PascalCase\tgsp", ':execute "normal \<Plug>CaserMixedCase"' ],
            \ [ "camelCase\tgsc", ':execute "normal \<Plug>CaserCamelCase"' ],
            \ [ "snake_case\tgs_", ':execute "normal \<Plug>CaserSnakeCase"' ],
            \ [ "UPPER_CASE\tgsu", ':execute "normal \<Plug>CaserUpperCase"' ],
            \ [ "Title Case\tgst", ':execute "normal \<Plug>CaserTitleCase"' ],
            \ [ "Sentence case\tgss", ':execute "normal \<Plug>CaserSentenceCase"' ],
            \ [ "space case\tgs<space>", ':execute "normal \<Plug>CaserSpaceCase"' ],
            \ [ "kebab-case\tgsk", ':execute "normal \<Plug>CaserKebabCase"' ],
            \ [ "Title-Dash-Case\tgsK", ':execute "normal \<Plug>CaserTitleKebabCase"' ],
            \ [ "dot.case\tgs.", ':execute "normal \<Plug>CaserDotCase"' ],
            \ ])

call quickui#menu#install("&Grep", [
            \ [ "File (<cword>)", ":call AsyncRunGrepCwordCurrentFile()" ],
            \ [ "File (pattern?)", ":call AsyncRunGrepCurrentFile()" ],
            \ [ "File IgnoreCase (<cword>)", ":call AsyncRunGrepCwordCurrentFileIgnoreCase()" ],
            \ [ "File IgnoreCase (pattern?)", ":call AsyncRunGrepCurrentFileIgnoreCase()" ],
            \ [ "--", "" ],
            \ [ "Project (<cword>,<cwd>)", ":call AsyncRunGrepCwordCwdRecursive()" ],
            \ [ "Project (pattern?,<cwd>)", ":call AsyncRunGrepCwdRecursive()" ],
            \ [ "Project (<cword>,file?)", ":call AsyncRunGrepCwordRecursive()" ],
            \ [ "Project (pattern?,file?)", ":call AsyncRunGrepRecursive()" ],
            \ [ "Project IgnoreCase (<cword>,<cwd>)", ":call AsyncRunGrepCwordCwdRecursiveIgnoreCase()" ],
            \ [ "Project IgnoreCase (pattern?,<cwd>)", ":call AsyncRunGrepCwdRecursiveIgnoreCase()" ],
            \ [ "Project IgnoreCase (<cword>,file?)", ":call AsyncRunGrepCwordRecursiveIgnoreCase()" ],
            \ [ "Project IgnoreCase (pattern?,file?)", ":call AsyncRunGrepRecursiveIgnoreCase()" ],
            \ ])

call quickui#menu#install("&Coc", [
            \ [ "&Find references", ':execute "normal \<Plug>(coc-references)"' ],
            \ [ "--", "" ],
            \ [ "GoTo &definition\tgd", ':execute "normal \<Plug>(coc-definition)"' ],
            \ [ "GoTo &references\tgr", ':execute "normal \<Plug>(coc-references)"' ],
            \ [ "GoTo &type\tgy", ':execute "normal \<Plug>(coc-type-definition)"' ],
            \ [ "GoTo &implementation\tgi", ':execute "normal \<Plug>(coc-implementation)"' ],
            \ [ "--", "" ],
            \ [ "Symbol Renaming\t<leader>rn", ':execute "normal \<Plug>(coc-rename)"' ],
            \ [ "Auto QuickFix\t<leader>qf", ':execute "normal \<Plug>(coc-fix-current)"' ],
            \ [ "Code Lens\t<leader>cl", ':execute "normal \<Plug>(coc-codelens-action)"' ],
            \ [ "--", "" ],
            \ [ "Diagnostic &prev\t[g", ':execute "normal \<Plug>(coc-diagnostic-prev)"' ],
            \ [ "Diagnostic &next\t]g", ':execute "normal \<Plug>(coc-diagnostic-next)"' ],
            \ [ "--", "" ],
            \ [ "Code Actions\t<leader>ac", ':execute "normal \<Plug>(coc-codeaction)"' ],
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
            \ [ "&NERDTree\t<leader><leader>1", ":NERDTreeToggle" ],
            \ [ "T&agbar\t<leader><leader>2", ":Tagbar" ],
            \ [ "&Quickfix\t<leader><leader>3", ":call OpmToggleQuickfixBuffer()" ],
            \ [ "&Terminal\t<leader><leader>4", ":call OpmToggleTerminalBuffer()" ],
            \ [ "&Gundo\t<leader><leader>5", ":GundoToggle" ],
            \ [ "--", "" ],
            \ [ "Quickfix Prev\t<F1>", ":cprevious" ],
            \ [ "Quickfix Next\t<F2>", ":cnext" ],
            \ [ "--", "" ],
            \ [ "Buffer Prev\t:bp", ":bp" ],
            \ [ "Buffer Next\t:bn", ":bn" ],
            \ ])

call quickui#menu#install("&Help", [
            \ ['Set &Spell (%{&spell? "Off":"On"})', 'set spell!'],
            \ ['Set Scroll&bind (%{&scrollbind? "Off":"On"})', 'set scrollbind!'],
            \ ['Set &Cursor Line (%{&cursorline? "Off":"On"})', 'set cursorline!'],
            \ ['Set &Paste (%{&paste? "Off":"On"})', 'set paste!'],
            \ ['Set &Wrap (%{&wrap? "Off":"On"})', 'set wrap!'],
            \ ["--", ""],
            \ ["Vim &Cheatsheet", "help index"],
            \ ["Vim T&ips", "help tips"],
            \ ["Vim &Tutorial", "help tutor"],
            \ ["Vim &Quick Reference", "help quickref"],
            \ ["Vim Config", "help config"],
            \ ["Opm Help", ":OpmHelp"],
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

