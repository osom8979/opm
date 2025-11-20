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

function! s:GetVisualSelectionBegin() abort
    let [line_start, column_start] = getpos("'<")[1:2]
    return [line_start, column_start]
endfunction

function! s:GetVisualSelectionEnd() abort
    let [line_end, column_end] = getpos("'>")[1:2]
    return [line_end, column_end]
endfunction

function! s:GetVisualSelection()
    let [line_start, column_start] = s:GetVisualSelectionBegin()
    let [line_end, column_end] = s:GetVisualSelectionEnd()

    if (line2byte(line_start) + column_start) > (line2byte(line_end) + column_end)
        let [line_start, column_start, line_end, column_end] = [line_end, column_end, line_start, column_start]
    endif

    let lines = getline(line_start, line_end)

    if empty(lines)
        return ''
    endif

    let lines[-1] = lines[-1][: column_end - (&selection ==# 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]

    return join(lines, "\n")
endfunction

function! s:GetCurrentFile() abort
    return expand('%:p')
endfunction

function! s:GetCurrentLine() abort
    return line('.')
endfunction

function! s:GetCurrentColumn() abort
    return col('.')
endfunction

if !exists('g:opm_quickui_current_file')
    let g:opm_quickui_current_file = ''
endif
if !exists('g:opm_quickui_current_line')
    let g:opm_quickui_current_line = 0
endif
if !exists('g:opm_quickui_current_column')
    let g:opm_quickui_current_column = 0
endif

if !exists('g:opm_quickui_selected_begin')
    let g:opm_quickui_selected_begin = []
endif
if !exists('g:opm_quickui_selected_end')
    let g:opm_quickui_selected_end = []
endif
if !exists('g:opm_quickui_selected_text')
    let g:opm_quickui_selected_text = ''
endif

function! OpenQuickuiMenuWithCopySelection(namespace)
    let g:opm_quickui_current_file = s:GetCurrentFile()
    let g:opm_quickui_current_line = s:GetCurrentLine()
    let g:opm_quickui_current_column = s:GetCurrentColumn()

    let g:opm_quickui_selected_begin = s:GetVisualSelectionBegin()
    let g:opm_quickui_selected_end = s:GetVisualSelectionEnd()
    let g:opm_quickui_selected_text = s:GetVisualSelection()

    call quickui#menu#open(a:namespace)
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
            \ [ "Diff update\t:diffupdate", ":diffupdate", "Update the diff highlighting and folds."],
            \ [ "Diff split\t:diffsplit", ":diffsplit" ],
            \ [ "Diff this\t:diffthis", ":diffthis" ],
            \ [ "Diff patch\t:diffpatch", ":diffpatch" ],
            \ [ "Diff off\t:diffoff", ":diffoff" ],
            \ [ "Diff jump forwards\t]c", ':call feedkeys("]c")' ],
            \ [ "Diff jump backwards\t[c", ':call feedkeys("[c")' ],
            \ [ "Diff get\t:diffget", ':diffget' ],
            \ [ "Diff put\t:diffput", ':diffput' ],
            \ [ "--", "" ],
            \ [ "Reload\t:e!", ":e!", "If you messed up the buffer and want to start all over again." ],
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
            \ [ "&Wiki/4Space to Asterisk", ":%s/^    /* / | %s/    /*/g" ],
            \ [ "Wiki/Not list is H2", ':%s/^\([^\*].*\)/== \1 ==/' ],
            \ [ "Wiki/Not list is H3", ':%s/^\([^\*].*\)/=== \1 ===/' ],
            \ [ "Wiki/Not list is H4", ':%s/^\([^\*].*\)/==== \1 ====/' ],
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

call quickui#menu#install("&Navigation", [
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
            \ [ "--", "" ],
            \ [ "Stop highlighting\t:nohlsearch", ":nohlsearch", "Stop the highlighting for the 'hlsearch' option." ],
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
            \ [ "Code Formatting\t<leader>f", ':execute "normal \<Plug>(coc-format-selected)"', 'Currently not working' ],
            \ [ "--", "" ],
            \ [ "File Formatting", ':CocCommand editor.action.formatDocument' ],
            \ [ "--", "" ],
            \ [ "Diagnostic &prev\t[g", ':execute "normal \<Plug>(coc-diagnostic-prev)"' ],
            \ [ "Diagnostic &next\t]g", ':execute "normal \<Plug>(coc-diagnostic-next)"' ],
            \ [ "--", "" ],
            \ [ "Code Actions\t<leader>ac", ':execute "normal \<Plug>(coc-codeaction)"' ],
            \ [ "--", "" ],
            \ [ "Install clangd", ':CocCommand clangd.install' ],
            \ [ "--", "" ],
            \ [ "Edit workspace settings", ':CocLocalConfig' ],
            \ [ "Edit user settings", ':CocConfig' ],
            \ ])

call quickui#menu#install("&Debug", [
            \ [ "&Launch\tS-F9", ':execute "normal \<Plug>VimspectorLaunch"' ],
            \ [ "Reset", ':VimspectorReset' ],
            \ [ "--", "" ],
            \ [ "&Continue\tF9", ':execute "normal \<Plug>VimspectorContinue"' ],
            \ [ "&Stop\tC-F2", ':execute "normal \<Plug>VimspectorStop"' ],
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

call quickui#menu#install("&Tools", [
            \ [ "Git &log", ':Git log' ],
            \ [ "Git &blame", ':Git blame' ],
            \ [ "--", "" ],
            \ [ "Claude Code Autocomplete\t<leader><Space>", ':call OpmClaudeCodeAutocomplete()' ],
            \ ])

call quickui#menu#install("&View", [
            \ [ "E&xchange Next Window\t<C-w>x", ':call feedkeys("\<C-w>x")' ],
            \ [ "--", "" ],
            \ [ "&NERDTree\t<leader><leader>1", ":NERDTreeToggle" ],
            \ [ "T&agbar\t<leader><leader>2", ":Tagbar" ],
            \ [ "&Quickfix\t<leader><leader>3", ":call OpmToggleQuickfixBuffer()" ],
            \ [ "&Terminal\t<leader><leader>4", ":call OpmToggleTerminalBuffer()" ],
            \ [ "&Gundo\t<leader><leader>5", ":GundoToggle" ],
            \ [ "&ClaudeCursor\t<leader><leader>6", ":ClaudeCursorToggle" ],
            \ [ "--", "" ],
            \ [ "Quickfix Prev\t<F1>", ":cprevious" ],
            \ [ "Quickfix Next\t<F2>", ":cnext" ],
            \ [ "--", "" ],
            \ [ "Buffer Prev\t:bp", ":bp" ],
            \ [ "Buffer Next\t:bn", ":bn" ],
            \ [ "--", "" ],
            \ [ "Tab Prev\t:tabp", ":tabp" ],
            \ [ "Tab Next\t:tabn", ":tabn" ],
            \ ])

call quickui#menu#install("&Help", [
            \ [ 'Set &Spell (%{&spell? "Off":"On"})', 'set spell!'],
            \ [ 'Set Scroll&bind (%{&scrollbind? "Off":"On"})', 'set scrollbind!'],
            \ [ 'Set &Cursor Line (%{&cursorline? "Off":"On"})', 'set cursorline!'],
            \ [ 'Set &Paste (%{&paste? "Off":"On"})', 'set paste!'],
            \ [ 'Set &Wrap (%{&wrap? "Off":"On"})', 'set wrap!'],
            \ [ "--", "" ],
            \ [ 'Tree-sitter highlight ON', ':TSBufEnable highlight'],
            \ [ 'Tree-sitter highlight OFF', ':TSBufDisable highlight'],
            \ [ "--", "" ],
            \ [ "Vim &Cheatsheet", "help index" ],
            \ [ "Vim T&ips", "help tips" ],
            \ [ "Vim &Tutorial", "help tutor" ],
            \ [ "Vim &Quick Reference", "help quickref" ],
            \ [ "Digraph Table", "help digraph-table" ],
            \ [ "Unicode Table", ":UnicodeTable" ],
            \ [ "Opm Help", ":OpmHelp" ],
            \ [ "--", "" ],
            \ [ "Print file path (relative)\tC-G", ":echo @%" ],
            \ [ "Print file path (absolute)", ":echo expand('%:p')" ],
            \ [ "--", "" ],
            \ [ "Show History", ":history" ],
            \ [ "Show Leaders", ":verbose map <leader>" ],
            \ [ "--", "" ],
            \ [ "&Loaded Scripts", ":OpmLoadedScripts" ],
            \ [ "Healthcheck", ":checkhealth" ],
            \ [ "--", "" ],
            \ [ "Put mapping", ":put =execute('verbose map')" ],
            \ [ "Put <leader> mapping", ":put =execute('verbose map <leader>')" ],
            \ [ "Put input mapping", ":put =execute('verbose imap')" ],
            \ [ "--", "" ],
            \ [ "Clear\t:mode", ":mode", "Clears and redraws the screen" ],
            \ [ "OPM &Reload", ":OpmReload" ],
            \ ], 10000)

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" -----------
" Key mapping
" -----------

silent execute 'noremap '.g:opm_default_quickui_toggle_key.' <ESC>:call OpenQuickuiMenuWithCopySelection(g:opm_default_quickui_namespace)<CR>'

