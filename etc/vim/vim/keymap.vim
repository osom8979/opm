"" Key-map & command setting.

let mapleader="\\"

" Common setting.
" Yanked text to vi command prompt: <C-r>"

" Terminal settings.
if has('nvim')
tnoremap <ESC> <C-\><C-n>
endif

" Open window.
noremap  <leader><leader>1  <ESC>:NERDTreeToggle<CR>
noremap  <leader><leader>2  <ESC>:Tagbar<CR>
noremap  <leader><leader>3  <ESC>:call ToggleQuickfixBuffer()<CR>
noremap  <leader><leader>4  <ESC>:call ToggleTerminalBuffer()<CR>
noremap  <leader><leader>5  <ESC>:GundoToggle<CR>
"noremap <leader><leader>8  <ESC>:SrcExplToggle<CR>

" Jump NERDTree window.
noremap  <leader>1  <ESC>:NERDTreeFocus<CR>

" Buffer settings.
noremap  <F1>       <ESC>:call MovePrevModifiableBuffer()<CR>
noremap  <F2>       <ESC>:call MoveNextModifiableBuffer()<CR>
noremap  <leader>w  <ESC>:call CloseAndMoveNextBuffer()<CR>
noremap  <leader>W  <ESC>:call CloseAnotherBuffer()<CR>

" Clipboard settings.
noremap  <F3> "+Y
noremap  <F4> "+gP
vnoremap <F3> "+y
vnoremap <F4> "+gP
inoremap <F4> <ESC>"+gpa

" Tab settings.
noremap <leader><F1>  <ESC>:tabprevious<CR>
noremap <leader><F2>  <ESC>:tabNext<CR>

" Quick-fix settings.
noremap <F5>  <ESC>:cprevious<CR>
noremap <F6>  <ESC>:cnext<CR>

" Tags settings.
noremap  <leader>t <ESC>:tags<CR>
noremap  <leader>[ <ESC>:tprevious<CR>
noremap  <leader>] <ESC>:tnext<CR>

" SnipMate key
" Integrate YouCompleteMe issue
" https://github.com/Valloric/YouCompleteMe/issues/47
imap <C-J> <ESC>a<Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

" ----------------
" COMMAND SETTING.
" ----------------

command! Reload         execute 'source ~/.vimrc'
command! HexMode        execute '%!xxd'
command! TextMode       execute '%!xxd -r'
command! Help           execute ':call PrintHelpMessage()'
command! LoadedScripts  execute ':scriptnames'
command! JsonFormat     execute ':%!python -m json.tool'

" --------------
" GREP SETTINGS.
" --------------

command! -nargs=* -bang GrepQuickFix call QuickFixGrepCommand(<bang>0, <q-args>)
cnoreabbrev grepq  GrepQuickFix

command! -nargs=* GrepRecursive execute ':AsyncRun grep -Iirn ' . <q-args> . ' <cwd>'
cnoreabbrev grepr GrepRecursive

" -------------------
" DEBUGGING SETTINGS.
" -------------------

function! OpmDebugStepInto()
    if exists(':TStep') == 2
        execute ':TStep'
    elseif exists(':Step') == 2
        execute ':Step'
    endif
endfunction

function! OpmDebugStepOver()
    if exists(':TNext') == 2
        execute ':TNext'
    elseif exists(':Over') == 2
        execute ':Over'
    endif
endfunction

function! OpmDebugFinish()
    if exists(':TFinish') == 2
        execute ':TFinish'
    elseif exists(':Finish') == 2
        execute ':Finish'
    endif
endfunction

function! OpmDebugContinue()
    if exists(':TContinue') == 2
        execute ':TContinue'
    elseif exists(':Continue') == 2
        execute ':Continue'
    endif
endfunction

noremap         <F7>  <ESC>:call OpmDebugStepInto()<CR>
noremap         <F8>  <ESC>:call OpmDebugStepOver()<CR>
noremap <leader><F8>  <ESC>:call OpmDebugFinish()<CR>

" Run Termdbg {debugger} {file}
" :TLocateCursor Locate cursor to running line
" :TToggleBreak Toggle breakpoint in current line
" :TSendCommand Send command to debugger

" `:Run` [args]	    run the program with [args] or the previous arguments
" `:Arguments` {args}  set arguments for the next `:Run`
" *:Break*	set a breakpoint at the current line; a sign will be displayed
" *:Clear*	delete the breakpoint at the current line
" *:Stop*	interrupt the program

" ----------
" QuickMenu.
" ----------

let g:opm_quickmenu_id = 100
let g:opm_quickmenu_mode_id = 101
let g:opm_build_mode = 'debug'

noremap <leader>` <ESC>:call quickmenu#toggle(g:opm_quickmenu_id)<CR>

function! OpmReloadQuickMenu()
    call quickmenu#current(g:opm_quickmenu_id)
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

call OpmReloadQuickMenu()

"" -----------------
"" Command & KeyMap.
"" -----------------

" command! -nargs=0 -bang               OpvimPreview  call opvim#Preview(<bang>0)
" command! -nargs=? -complete=shellcmd  OpvimExec     call opvim#Exec(<f-args>)
" command! -nargs=?                     OpvimMode     call opvim#Mode(<f-args>)
" command! -nargs=0                     OpvimModeMenu call quickmenu#bottom(g:opm_quickmenu_mode_id)
" command! -nargs=0                     OpvimCMake    call opvim#CMake()
" command! -nargs=?                     OpvimBuild    call opvim#Build(<f-args>)
" command! -nargs=?                     OpvimDebug    call opvim#Debug(<f-args>)
" command! -nargs=?                     OpvimScript   call opvim#Script(<f-args>)
" command! -nargs=0                     OpvimReload   call OpmReloadQuickMenu()
" command! -nargs=0                     OpvimCreate   call opvim#CreateProject()
" command! -nargs=0 OpvimDebugDone call opvim#ExitDebug()

"" -------
"" coc.vim
"" -------

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

