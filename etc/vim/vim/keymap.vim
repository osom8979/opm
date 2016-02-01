"" Key-map & command setting.

let mapleader="\\"

" Common setting.
" Yanked text to vi command prompt: <C-r>"

" Help message.
"noremap <leader>? <ESC>:call OpmHelp()<CR>

" Buffer setting.
noremap  <F1>      :call MovePrevModifiableBuffer()<CR>
noremap  <F2>      :call MoveNextModifiableBuffer()<CR>
nnoremap <leader>w :call CloseAndMoveNextBuffer()<CR>
nnoremap <leader>W :call CloseAnotherBuffer()<CR>

" Clipboard setting.
noremap  <F3> "+Y
noremap  <F4> "+gP
vnoremap <F3> "+y
vnoremap <F4> "+gP
inoremap <F4> <ESC>"+gpa

" Ctags setting.
nnoremap  <leader>t :tselect <C-R>=expand("<cword>")<CR><CR>
nnoremap  <leader>{ :tp<CR>
nnoremap  <leader>} :tn<CR>

" Cscope setting.
nnoremap  <C-\>s  :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>g  :cs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>c  :cs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>t  :cs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>e  :cs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>f  :cs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap  <C-\>i  :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap  <C-\>d  :cs find d <C-R>=expand("<cword>")<CR><CR>

nnoremap  <leader>[ :cp<CR>
nnoremap  <leader>] :cn<CR>

" OmniCppComplete popup menu.
"inoremap  <leader><space>  <C-x><C-o>

" vim-easymotion setting.
" Find next: <leader><leader>f
" Find prev: <leader><leader>F

" ---------------
" WINDOW SETTING.
" ---------------

" Open window.
nnoremap  <leader><leader>1  :NERDTreeToggle<CR>
nnoremap  <leader><leader>2  :Tagbar<CR>
"nnoremap <leader><leader>3  :cwindow<CR>
"nnoremap <leader><leader>3  :GundoToggle<CR>
"nnoremap <leader><leader>4  :SrcExplToggle<CR>

" Jump NERDTree window.
nnoremap  <leader>1  :NERDTreeFocus<CR>
nnoremap  <leader>2  :NERDTreeFocus<CR><C-w>w

" Open ctrlp window.
"noremap <leader><leader>o :CtrlP<CR>

" ----------------
" COMMAND SETTING.
" ----------------

command! Reload    execute 'source ~/.vimrc'
command! HexMode   execute '%!xxd'
command! TextMode  execute '%!xxd -r'

