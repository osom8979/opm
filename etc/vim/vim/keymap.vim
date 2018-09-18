"" Key-map & command setting.

let mapleader="\\"

" Common setting.
" Yanked text to vi command prompt: <C-r>"

" Help message.
"noremap <leader>? <ESC>:call OpmHelp()<CR>

" Buffer settings.
noremap  <F1>      :call MovePrevModifiableBuffer()<CR>
noremap  <F2>      :call MoveNextModifiableBuffer()<CR>
nnoremap <leader>w :call CloseAndMoveNextBuffer()<CR>
nnoremap <leader>W :call CloseAnotherBuffer()<CR>

" Tab settings.
"nnoremap <leader><F1>   :tabprevious<CR>
"nnoremap <leader><F2>   :tabNext<CR>

" Clipboard settings.
noremap  <F3> "+Y
noremap  <F4> "+gP
vnoremap <F3> "+y
vnoremap <F4> "+gP
inoremap <F4> <ESC>"+gpa

" Makefile settings.
nnoremap <F9>                   :make<CR>:copen<CR>
nnoremap <leader><leader><F1>   :cprevious<CR>
nnoremap <leader><leader><F2>   :cnext<CR>

" Ctags settings.
"nnoremap  <leader>t :tselect <C-R>=expand("<cword>")<CR><CR>
"nnoremap  <leader>{ :tp<CR>
"nnoremap  <leader>} :tn<CR>

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

" QuickMenu
noremap <silent><F12> :call quickmenu#toggle(0)<CR>

" ---------------
" WINDOW SETTING.
" ---------------

" Open window.
nnoremap  <leader><leader>1  :NERDTreeToggle<CR>
nnoremap  <leader><leader>2  :Tagbar<CR>
nnoremap  <leader><leader>3  :call ToggleQuickfixBuffer()<CR>
"nnoremap <leader><leader>3  :GundoToggle<CR>
"nnoremap <leader><leader>4  :SrcExplToggle<CR>

" Jump NERDTree window.
nnoremap  <leader>1  :NERDTreeFocus<CR>
nnoremap  <leader>2  :NERDTreeFocus<CR><C-w>w

" Open ctrlp window.
"noremap <leader><leader>o :CtrlP<CR>

" ----------------------
" Terminal Mode SETTING.
" ----------------------

if has('nvim')
tnoremap <Esc> <C-\><C-n>
endif

" ----------------
" COMMAND SETTING.
" ----------------

command! Reload    execute 'source ~/.vimrc'
command! HexMode   execute '%!xxd'
command! TextMode  execute '%!xxd -r'
command! Help      execute ':call PrintHelpMessage()'

