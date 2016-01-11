"" Key map setting.

let mapleader="\\"

" Help message.
noremap <leader>? <ESC>:call OpmHelp()<CR>

" Buffer setting.
noremap  <F1> <ESC>:bp<CR>
noremap  <F2> <ESC>:bn<CR>
nnoremap <leader>w :call CloseBufferAndMoveNext()<CR>

" Clipboard setting.
noremap  <F11> "+Y
noremap  <F12> "+gP
vnoremap <F11> "+y
vnoremap <F12> "+gP
inoremap <F12> <ESC>"+gpi

" Ctags setting.
nnoremap <leader>t :tselect <C-R>=expand("<cword>")<CR><CR>

" Cscope setting.
nnoremap  <C-\>s  :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>g  :cs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>c  :cs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>t  :cs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>e  :cs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap  <C-\>f  :cs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap  <C-\>i  :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap  <C-\>d  :cs find d <C-R>=expand("<cword>")<CR><CR>

nnoremap  <leader>[ :cn
nnoremap  <leader>] :cp

" ---------------
" LEADER SETTING.
" ---------------

" Open window.
nnoremap  <leader><leader>1  :NERDTreeToggle<CR>
nnoremap  <leader><leader>2  :Tagbar<CR>
nnoremap  <leader><leader>3  :cwindow<CR>
"nnoremap <leader><leader>3  :GundoToggle<CR>
"nnoremap <leader><leader>4  :SrcExplToggle<CR>

" Jump window.
nnoremap  <leader>1  :NERDTreeFocus<CR>

" Open ctrlp window.
"noremap <leader><leader>o :CtrlP<CR>

