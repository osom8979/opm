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

" Conflict list (Don't use this plugins).
"NeoBundle 'wesleyche/SrcExpl'         " displaying prototype (Conflict from the ctags.vim).

NeoBundle 'scrooloose/nerdtree'        " directory browser.
NeoBundle 'kien/ctrlp.vim'             " full path fuzzy file, buffer, mru, tag, etc.
NeoBundle 'majutsushi/tagbar'          " tagbar window.
NeoBundle 'easymotion/vim-easymotion'  " motions on speed.
NeoBundle 'kshenoy/vim-signature'      " display marks.
NeoBundle 'scrooloose/nerdcommenter'   " language dependent commenter.
"NeoBundle 'edkolev/promptline.vim'    " generate a fast shell prompt.
"NeoBundle 'tpope/vim-surround'        " quoting/parenthesizing made simple.
"NeoBundle 'scrooloose/syntastic'      " syntax checking.
"NeoBundle 'sjl/gundo.vim'             " undo tree.
"NeoBundle 'zakj/vim-showmarks'        " show mark list bar.
NeoBundle 'scrooloose/syntastic'       " syntax checking hacks for vim.

" vim-airline.
NeoBundle 'vim-airline/vim-airline-themes'
NeoBundle 'vim-airline/vim-airline'

" SnipMate.
NeoBundle 'MarcWeber/vim-addon-mw-utils'
NeoBundle 'tomtom/tlib_vim'
NeoBundle 'garbas/vim-snipmate'

NeoBundle 'ctags.vim'   " ctags plugin (Conflict from the SrcExpl).
NeoBundle 'cscope.vim'  " cscope plugin.

NeoBundle 'matchparenpp'  " blink match brace.
NeoBundle 'echofunc.vim'  " print function parameter information.
NeoBundle 'a.vim'         " source <-> header.

" Auto completion.
NeoBundle 'AutoComplPop'    " auto complete popup.
NeoBundle 'OmniCppComplete' " Ctags auto complete popup.

" Themes
"NeoBundle 'nanotech/jellybeans.vim'

" C/C++ supported.
if has('win32')
    NeoBundle '~/.vim/bundle/YouCompleteMe-windows-733de48-x86', {
    \   'type' : 'nosync'
    \ }
else
    NeoBundle 'Valloric/YouCompleteMe'
endif

if has('nvim')
NeoBundle 'sakhnik/nvim-gdb' " Neovim thin wrapper for GDB, LLDB and PDB.
endif

" Rails supported.
NeoBundle 'tpope/vim-rails'

" Python supported.
if has('python')
NeoBundle 'klen/python-mode'
endif

"if has("netbeans_intg")
"    NeoBundle '~/.vim/bundle/pyclewn-2.0.1', {
"    \   'type' : 'nosync'
"    \ }
"endif

" Git supported.
NeoBundle 'airblade/vim-gitgutter' " shows a git diff in the gutter.
NeoBundle 'tpope/vim-fugitive'     " git wrapper.

" Miscellaneous utilities.
NeoBundle 'visSum.vim'  " computes sum of selected numbers. Use the :VisSum in VisualMode.
NeoBundle 'VisIncr'     " produce increasing/decreasing columns. Usage: :ll or :ll -1

call neobundle#end()

filetype plugin indent on
NeoBundleCheck

