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

" Makefile settings.
"nnoremap <F9> :make<CR>:copen<CR>

" Tags settings.
noremap  <leader>t <ESC>:tags<CR>
noremap  <leader>[ <ESC>:tprevious<CR>
noremap  <leader>] <ESC>:tnext<CR>

" Cscope settings.
"nnoremap  <C-\>s  :cs find s <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <C-\>g  :cs find g <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <C-\>c  :cs find c <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <C-\>t  :cs find t <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <C-\>e  :cs find e <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <C-\>f  :cs find f <C-R>=expand("<cfile>")<CR><CR>
"nnoremap  <C-\>i  :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
"nnoremap  <C-\>d  :cs find d <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <leader>[ :cp<CR>
"nnoremap  <leader>] :cn<CR>

" OmniCppComplete popup menu.
"inoremap  <leader><space>  <C-x><C-o>

" SnipMate key
" Integrate YouCompleteMe issue
" https://github.com/Valloric/YouCompleteMe/issues/47
imap <C-J> <ESC>a<Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

" Open ctrlp window.
"noremap <leader><leader>o :CtrlP<CR>

" YouCompleteMe
noremap  <leader>gg  <ESC>:YcmCompleter GoTo<CR>

" ----------------
" COMMAND SETTING.
" ----------------

command! Reload         execute 'source ~/.vimrc'
command! HexMode        execute '%!xxd'
command! TextMode       execute '%!xxd -r'
command! Help           execute ':call PrintHelpMessage()'

command! CMake          execute 'OpvimCMake'
command! Build          execute 'OpvimBuild'

command! RunGrep        execute ':AsyncRun! -cwd=<root> grep -Irn <cword> .'

command! LoadedScripts  execute ':scriptnames'

command! JsonFormat     execute ':%!python -m json.tool'

