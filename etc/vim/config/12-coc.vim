let s:plugin_name = 'coc.nvim'
let s:plugin_homepage = 'https://github.com/neoclide/coc.nvim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

" Global extension names to install when they aren't installed.
let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-go',
    \ 'coc-metals',
    \ 'coc-omnisharp',
    \ 'coc-jedi',
    \ 'coc-rls',
    \ 'coc-sh',
    \ 'coc-snippets',
    \ 'coc-tasks',
    \ 'coc-tsserver',
    \ 'coc-vetur',
    \]

" [WARN]
" Extension "coc-lists" registered synchronized autocmd "VimLeavePre",
" which could be slow.

let g:coc_disable_startup_warning = 1
let g:coc_node_path = g:opn_node_path
"let g:coc_config_home = g:opm_vim_script_dir.'/config/plugin'

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000ms=4s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" " Always show the signcolumn, otherwise it would shift the text each time
" " diagnostics appear/become resolved.
" if has("patch-8.1.1564")
"     " Recently vim can merge signcolumn and number column into one
"     set signcolumn=number
" else
"     set signcolumn=yes
" endif

" -----------------------------------------------
" Copy and paste right after 'set signcolumn=yes'
" of 'Example vim configuration' on the homepage.
" -----------------------------------------------

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1):
            \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" -------------
" coc workspace
" -------------

autocmd FileType python let b:coc_root_patterns = [
    \   '.git',
    \   '.env',
    \   'setup.cfg',
    \   'setup.py',
    \   'pyproject.toml',
    \]

autocmd FileType javascript,typescript let b:coc_root_patterns = [
    \   '.git',
    \   '.env',
    \   'project.json',
    \]

" ----------
" coc config
" ----------

call coc#config('suggest', {
    \   'noselect': v:true,
    \})

call coc#config('python', {
    \   'pythonPath': g:opy3_python_path,
    \   'jediEnabled': v:false,
    \   'autoComplete': {
    \       'extraPaths': [getcwd()],
    \   },
    \   'formatting': {
    \       'provider': 'black',
    \   },
    \   'linting': {
    \       'enabled': v:true,
    \       'flake8Enabled': v:true,
    \       'flake8Args': [
    \           '--extend-ignore=E203,W503',
    \           '--max-line-length=88',
    \           '--exclude=*_pb2.py,*_pb2_grpc.py',
    \       ],
    \       'banditEnabled': v:false,
    \       'mypyEnabled': v:false,
    \       'pep8Enabled': v:false,
    \       'prospectorEnabled': v:false,
    \       'pydocstyleEnabled': v:false,
    \       'pylamaEnabled': v:false,
    \       'pylintEnabled': v:false,
    \   },
    \})

call coc#config('jedi', {
    \   'executable': {
    \       'command': 'jedi-language-server',
    \       'args': [],
    \   },
    \})

call coc#config('languageserver', {
    \   'ccls': {
    \       'command': 'ccls',
    \       'trace.server': 'verbose',
    \       'filetypes': ['c', 'cpp', 'objc', 'objcpp']
    \       'rootPatterns': ['.ccls', 'compile_commands.json', '.git/', '.hg/'],
    \       'initializationOptions': {
    \           'cache': {
    \               'directory': '/tmp/ccls'
    \           }
    \       }
    \   },
    \   'csharp-ls': {
    \       'command': 'csharp-ls',
    \       'filetypes': ['cs'],
    \       'rootPatterns': ['*.csproj', '.vim/', '.git/', '.hg/']
    \   },
    \   'godot': {
    \       'host': '127.0.0.1',
    \       'filetypes': ['gdscript'],
    \       'port': 6005
    \   }
    \})


" ---------------------------------
" CTRL+P - Show Function Parameters
" ---------------------------------

" inoremap <silent> <c-p> <ESC>:call CocActionAsync('showSignatureHelp')<CR>
inoremap <C-P> <C-\><C-O>:call CocActionAsync('showSignatureHelp')<CR>

" ------------
" coc-snippets
" ------------

call coc#config('snippets', {
    \   'ultisnips': {
    \       'enable': v:false
    \   },
    \   'snipmate': {
    \       'enable': v:true
    \   }
    \})

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

