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
    \'build': {
    \       'windows': 'tools\\update-dll-mingw',
    \       'cygwin' : 'make -f make_cygwin.mak',
    \       'mac'    : 'make -f make_mac.mak',
    \       'linux'  : 'make',
    \       'unix'   : 'gmake',
    \   },
    \}

NeoBundle 'scrooloose/nerdtree'             " directory browser.
NeoBundle 'scrooloose/nerdcommenter'        " language dependent commenter.
NeoBundle 'ctrlpvim/ctrlp.vim'              " full path fuzzy file, buffer, mru, tag, etc.
NeoBundle 'majutsushi/tagbar'               " tagbar window.
NeoBundle 'easymotion/vim-easymotion'       " motions on speed.
NeoBundle 'kshenoy/vim-signature'           " display marks.
NeoBundle 'visSum.vim'                      " computes sum of selected numbers. Use the :VisSum in VisualMode.
NeoBundle 'sjl/gundo.vim'                   " undo tree.
NeoBundle 'VisIncr'                         " produce increasing/decreasing columns. Usage: :II or :II -1
NeoBundle 'skywind3000/asynctasks.vim'      " modern task system.
NeoBundle 'skywind3000/asyncrun.vim'        " run async shell commands.
NeoBundle 'skywind3000/quickmenu.vim'       " a nice customizable popup menu for vim.
NeoBundle 'ryanoasis/vim-devicons'          " Adds file type icons to Vim plugins
NeoBundle 'echofunc.vim'                    " print function parameter information.
NeoBundle 'a.vim'                           " source <-> header.
NeoBundle 'epheien/termdbg'                 " terminal debugger for vim
NeoBundle 'vim-airline/vim-airline-themes'  " [AirLine]
NeoBundle 'vim-airline/vim-airline'         " [AirLine]
NeoBundle 'MarcWeber/vim-addon-mw-utils'    " [Snip] dependency of 'vim-snipmate'
NeoBundle 'tomtom/tlib_vim'                 " [Snip] dependency of 'vim-snipmate'
NeoBundle 'garbas/vim-snipmate'             " [Snip] snipmate aims to provide support for textual snippets.
NeoBundle 'airblade/vim-gitgutter'          " [Git] shows a git diff in the gutter.
NeoBundle 'tpope/vim-fugitive'              " [Git] git wrapper.

" intellisense engine.
NeoBundle 'neoclide/coc.nvim', 'release', {
    \   'build': {
    \       'others': 'git checkout release'
    \   }
    \}

" OPM-VIM.
if $DISABLE_OPVIM != 1 && has('nvim') && has('python3')
    NeoBundle g:opm_vim_script_dir . '/opvim', {
        \   'type': 'nosync'
        \}
endif

call neobundle#end()

filetype plugin indent on
NeoBundleCheck

