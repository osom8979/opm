" plugins settings.
" Use the NeoBundle.vim plugin manager.

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

" -------
" Plugins
" -------

NeoBundle 'scrooloose/nerdtree'             " directory browser.
NeoBundle 'scrooloose/nerdcommenter'        " language dependent commenter.
NeoBundle 'Xuyuanp/nerdtree-git-plugin'     " showing git status flags.
NeoBundle 'majutsushi/tagbar'               " tagbar window.
NeoBundle 'easymotion/vim-easymotion'       " motions on speed.
NeoBundle 'kshenoy/vim-signature'           " display marks.
NeoBundle 'visSum.vim'                      " computes sum of selected numbers. Use the :VisSum in VisualMode.
NeoBundle 'sjl/gundo.vim'                   " undo tree.
NeoBundle 'VisIncr'                         " produce increasing/decreasing columns. Usage: :II or :II -1
NeoBundle 'skywind3000/asynctasks.vim'      " modern task system.
NeoBundle 'skywind3000/asyncrun.vim'        " run async shell commands.
NeoBundle 'skywind3000/vim-quickui'         " ui extensions for vim.
NeoBundle 'ryanoasis/vim-devicons'          " adds file type icons to vim plugins
NeoBundle 'echofunc.vim'                    " print function parameter information.
NeoBundle 'a.vim'                           " source <-> header.
NeoBundle 'epheien/termdbg'                 " terminal debugger for vim (pdb, ipdb, lldb, dlv)
NeoBundle 'vim-airline/vim-airline-themes'  " [AirLine]
NeoBundle 'vim-airline/vim-airline'         " [AirLine]
NeoBundle 'MarcWeber/vim-addon-mw-utils'    " [Snip] dependency of 'vim-snipmate'
NeoBundle 'tomtom/tlib_vim'                 " [Snip] dependency of 'vim-snipmate'
NeoBundle 'garbas/vim-snipmate'             " [Snip] snipmate aims to provide support for textual snippets.
NeoBundle 'airblade/vim-gitgutter'          " [Git] shows a git diff in the gutter.
NeoBundle 'tpope/vim-fugitive'              " [Git] git wrapper.
NeoBundle 'neoclide/coc.nvim'               " Intellisense engine.
NeoBundle 'KangOl/vim-pudb'                 " Manage pudb breakpoints.

" A command-line fuzzy finder.
NeoBundle 'junegunn/fzf', {
    \   'do': {
    \       -> fzf#install()
    \   }
    \}

" Interactive command execution in Vim.
NeoBundle 'Shougo/vimproc.vim', {
    \   'build': {
    \       'windows': 'tools\\update-dll-mingw',
    \       'cygwin' : 'make -f make_cygwin.mak',
    \       'mac'    : 'make -f make_mac.mak',
    \       'linux'  : 'make',
    \       'unix'   : 'gmake',
    \   },
    \}

" opm-vim
NeoBundle g:opm_vim_script_dir.'/opvim', {
    \   'type': 'nosync'
    \}

call neobundle#end()

filetype plugin indent on
NeoBundleCheck

" Native Package Support.
packadd termdebug

