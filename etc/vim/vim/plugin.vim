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
NeoBundle 'ctrlpvim/ctrlp.vim'         " full path fuzzy file, buffer, mru, tag, etc.
NeoBundle 'majutsushi/tagbar'          " tagbar window.
NeoBundle 'easymotion/vim-easymotion'  " motions on speed.
NeoBundle 'kshenoy/vim-signature'      " display marks.
NeoBundle 'scrooloose/nerdcommenter'   " language dependent commenter.
NeoBundle 'sjl/gundo.vim'              " undo tree.
"NeoBundle 'edkolev/promptline.vim'    " generate a fast shell prompt.
"NeoBundle 'tpope/vim-surround'        " quoting/parenthesizing made simple.
"NeoBundle 'zakj/vim-showmarks'        " show mark list bar.
NeoBundle 'scrooloose/syntastic'       " syntax checking hacks for vim.

" vim-airline.
NeoBundle 'vim-airline/vim-airline-themes'
NeoBundle 'vim-airline/vim-airline'

" SnipMate.
NeoBundle 'MarcWeber/vim-addon-mw-utils' " dependency of 'vim-snipmate'
NeoBundle 'tomtom/tlib_vim'              " dependency of 'vim-snipmate'
NeoBundle 'garbas/vim-snipmate'          " snipmate aims to provide support for textual snippets.

NeoBundle 'ctags.vim'   " ctags plugin (Conflict from the SrcExpl).
NeoBundle 'cscope.vim'  " cscope plugin.

"NeoBundle 'matchparenpp' " blink match brace.
NeoBundle 'echofunc.vim'  " print function parameter information.
NeoBundle 'a.vim'         " source <-> header.

" CMake
"NeoBundle 'vhdirk/vim-cmake'

" Themes
"NeoBundle 'nanotech/jellybeans.vim'

" Clang-based themes
if has('nvim')
"NeoBundle 'arakashic/chromatica.nvim'  " clang based syntax highlighting for neovim.
"NeoBundle 'bbchung/Clamp'              " neovim plugin to highlight c-family code.
else
" For now, at least, color_coded is not supporting neovim.
"NeoBundleLazy 'jeaye/color_coded', {
"    \   'build': {
"    \       'unix': 'rm -f CMakeCache.txt && cmake . && make && make install',
"    \   },
"    \   'autoload': { 'filetypes' : ['c', 'cpp', 'objc', 'objcpp'] },
"    \   'build_commands' : ['cmake', 'make']
"    \}
endif

" Auto completion.
"NeoBundle 'OmniCppComplete' " Ctags auto complete popup.
"NeoBundle 'AutoComplPop'    " auto complete popup.

" C/C++ supported.
" if !$DISABLE_YCM && has('nvim')
"     if has('win32')
"         NeoBundle '~/.vim/bundle/YouCompleteMe-windows-733de48-x86', {
"         \   'type' : 'nosync'
"         \ }
"     else
"         " Compile command:
"         " git submodule update --init --recursive
"         " opy3 install.py --clang-completer
"         NeoBundle 'Valloric/YouCompleteMe'
"     endif
" endif

" Debugging supported.
" if has('nvim')
"     " Neovim thin wrapper for GDB, LLDB and PDB.
"     " NeoBundle 'sakhnik/nvim-gdb', { 'branch': 'legacy' }
"     " NeoBundle 'sakhnik/nvim-gdb', { 'do': './install.sh' }
"     NeoBundle 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }
" endif

" Rails supported.
" NeoBundle 'tpope/vim-rails'

" Golang supported.
"NeoBundle 'fatih/vim-go'

" Python supported.
"if has('python')
"NeoBundle 'klen/python-mode'
"endif

"if has("netbeans_intg")
"    NeoBundle '~/.vim/bundle/pyclewn-2.0.1', {
"    \   'type' : 'nosync'
"    \ }
"endif

" Git supported.
NeoBundle 'airblade/vim-gitgutter' " shows a git diff in the gutter.
NeoBundle 'tpope/vim-fugitive'     " git wrapper.

" Quickfix
"NeoBundle 'romainl/vim-qf'  " tame the quickfix window.

" Miscellaneous utilities.
NeoBundle 'visSum.vim'  " computes sum of selected numbers. Use the :VisSum in VisualMode.
NeoBundle 'VisIncr'     " produce increasing/decreasing columns. Usage: :II or :II -1

" Shell
NeoBundle 'skywind3000/asyncrun.vim'  " run async shell commands.

" Menu
NeoBundle 'skywind3000/quickmenu.vim'  " a nice customizable popup menu for vim.

" Icon
NeoBundle 'ryanoasis/vim-devicons'  " Adds file type icons to Vim plugins

" OPM-VIM.
if $DISABLE_OPVIM != 1 && has('nvim') && has('python3')
    NeoBundle g:opm_vim_script_dir . '/opvim', {
    \   'type' : 'nosync'
    \ }
endif

call neobundle#end()

filetype plugin indent on
NeoBundleCheck

