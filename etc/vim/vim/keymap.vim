"" Key map setting.

let mapleader="\\"

" Help message.
map <leader>? <ESC>:call OpmHelp()<CR>

" Clipboard setting.
map  <F3> "+Y
map  <F4> "+gp
vmap <F3> "+y
vmap <F4> "+gp
imap <F4> <ESC>"+gpi

" Change window setting.
map <leader>w <C-w>w
map <leader>W <C-w>W
imap <leader>w <ESC><C-w>w
imap <leader>W <ESC><C-w>W

" Ctags setting.
nmap <leader>t :tselect <C-R>=expand("<cword>")<CR><CR>

" Cscope setting.
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" ---------------
" LEADER SETTING.
" ---------------

" Open window.
map <leader><leader>1 :NERDTreeToggle<CR>
map <leader><leader>2 :Tagbar<CR>
map <leader><leader>3 :GundoToggle<CR>
map <leader><leader>4 :SrcExplToggle<CR>

" Jump window.
map <leader>1 :NERDTreeFocus<CR>

" Open ctrlp window.
"map <leader><leader>o :CtrlP<CR>

