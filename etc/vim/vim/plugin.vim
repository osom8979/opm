"" Plugins setting.
"" Use the NeoBundle.vim plugin manager.

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
    if &compatible
        set nocompatible
    endif

    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

"" ------------
"" Plugin list.
"" ------------

" Interactive command execution in Vim.
NeoBundle 'Shougo/vimproc.vim', {
    \ 'build' : {
    \   'windows' : 'tools\\update-dll-mingw',
    \   'cygwin'  : 'make -f make_cygwin.mak',
    \   'mac'     : 'make -f make_mac.mak',
    \   'linux'   : 'make',
    \   'unix'    : 'gmake',
    \   },
    \ }

NeoBundle 'scrooloose/nerdtree'        " directory browser.
"NeoBundle 'scrooloose/nerdcommenter'  " language dependent commenter.
"NeoBundle 'tpope/vim-fugitive'        " git wrapper.
NeoBundle 'kien/ctrlp.vim'             " full path fuzzy file, buffer, mru, tag, etc.
NeoBundle 'bling/vim-airline'          " more beautiful Status bar.
"NeoBundle 'edkolev/promptline.vim'    " generate a fast shell prompt.
"NeoBundle 'tpope/vim-surround'        " quoting/parenthesizing made simple.
NeoBundle 'majutsushi/tagbar'          " tagbar window.
"NeoBundle 'wesleyche/SrcExpl'         " displaying prototype (Conflict from the ctags.vim).
NeoBundle 'scrooloose/syntastic'       " syntax checking.
"NeoBundle 'sjl/gundo.vim'             " undo tree.
"NeoBundle 'zakj/vim-showmarks'        " show mark list bar.
NeoBundle 'easymotion/vim-easymotion'  " motions on speed.

NeoBundle 'ctags.vim'   " ctags plugin (Conflict from the SrcExpl).
NeoBundle 'cscope.vim'  " cscope plugin.

NeoBundle 'matchparenpp'  " blink match brace.
NeoBundle 'echofunc.vim'  " print function parameter information.
NeoBundle 'a.vim'         " source <-> header.

NeoBundle 'AutoComplPop'    " auto complete popup.
NeoBundle 'OmniCppComplete' " Ctags auto complete popup.

" Themes
"NeoBundle 'nanotech/jellybeans.vim'

" C/C++ supported.
"if has('win32')
"    NeoBundle '~/.vim/bundle/YouCompleteMe-windows-733de48-x86', {
"    \   'type' : 'nosync'
"    \ }
"else
"    NeoBundle 'Valloric/YouCompleteMe'
"endif

" Rails supported.
NeoBundle 'tpope/vim-rails'

" Python supported.
NeoBundle 'klen/python-mode'

"if has("netbeans_intg")
"    NeoBundle '~/.vim/bundle/pyclewn-2.0.1', {
"    \   'type' : 'nosync'
"    \ }
"endif

call neobundle#end()

filetype plugin indent on
NeoBundleCheck

