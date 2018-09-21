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
noremap  <leader><leader>=  <ESC>:GundoToggle<CR>
"noremap <leader><leader>8  <ESC>:SrcExplToggle<CR>

" Jump NERDTree window.
noremap  <leader>1  <ESC>:NERDTreeFocus<CR>
noremap  <leader>2  <ESC>:NERDTreeFocus<CR><C-w>w

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
nnoremap <leader><F1>  :tabprevious<CR>
nnoremap <leader><F2>  :tabNext<CR>

" Quick-fix settings.
nnoremap <F5>  :cprevious<CR>
nnoremap <F6>  :cnext<CR>

" Makefile settings.
"nnoremap <F9> :make<CR>:copen<CR>

" Tags settings.
nnoremap  <leader>t <ESC>:tags<CR>
nnoremap  <leader>[ <ESC>:tprevious<CR>
nnoremap  <leader>] <ESC>:tnext<CR>

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

" ----------------
" COMMAND SETTING.
" ----------------

command! Reload    execute 'source ~/.vimrc'
command! HexMode   execute '%!xxd'
command! TextMode  execute '%!xxd -r'
command! Help      execute ':call PrintHelpMessage()'

