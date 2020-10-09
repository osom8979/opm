"" Key-map & command setting.

let mapleader="\\"

" Terminal settings.
if has('nvim')
tnoremap <ESC> <C-\><C-n>
endif

" Open window.
noremap  <leader><leader>1  <ESC>:NERDTreeToggle<CR>
noremap  <leader><leader>2  <ESC>:Tagbar<CR>
"noremap <leader><leader>3  " It is already set in opm: NextBuffer
"noremap <leader><leader>4  " It is already set in opm: PrevBuffer
noremap  <leader><leader>5  <ESC>:GundoToggle<CR>
"noremap <leader><leader>8  <ESC>:SrcExplToggle<CR>

" Jump window.
noremap  <leader>1  <ESC>:NERDTreeFocus<CR>

" Tab settings.
noremap <leader><F1>  <ESC>:tabprevious<CR>
noremap <leader><F2>  <ESC>:tabNext<CR>

" Clipboard settings.
noremap  <F3>  "+Y
noremap  <F4>  "+gP
vnoremap <F3>  "+y
vnoremap <F4>  "+gP
inoremap <F4>  <ESC>"+gpa

" Quick-fix settings.
noremap  <F5>  <ESC>:cprevious<CR>
noremap  <F6>  <ESC>:cnext<CR>

" Tags settings.
noremap  <leader>t <ESC>:tags<CR>
noremap  <leader>[ <ESC>:tprevious<CR>
noremap  <leader>] <ESC>:tnext<CR>

" vim-snipmate key
" Integrate YouCompleteMe issue
" https://github.com/Valloric/YouCompleteMe/issues/47
imap <C-J> <ESC>a<Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

" ----------------
" COMMAND SETTING.
" ----------------

command! OpmReload         execute 'source ~/.vimrc'
command! OpmHexMode        execute '%!xxd'
command! OpmTextMode       execute '%!xxd -r'
command! OpmLoadedScripts  execute ':scriptnames'
command! OpmJsonFormat     execute ':%!python -m json.tool'

" --------------
" GREP SETTINGS.
" --------------

command! -nargs=* GrepRecursive execute ':AsyncRun grep -Iirn ' . <q-args> . ' <cwd>'
cnoreabbrev grepr GrepRecursive

