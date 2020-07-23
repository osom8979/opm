
" =======================================
" Conflict list (Don't use this plugins).

"NeoBundle 'wesleyche/SrcExpl'         " displaying prototype (Conflict from the ctags.vim).

" ==============
" Error plugins.

"NeoBundle 'matchparenpp'   " blink match brace.

" ================
" Disable plugins.

"NeoBundle 'edkolev/promptline.vim'    " generate a fast shell prompt.
"NeoBundle 'tpope/vim-surround'        " quoting/parenthesizing made simple.
"NeoBundle 'zakj/vim-showmarks'        " show mark list bar.

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
    "\   'build': {
    "\       'unix': 'rm -f CMakeCache.txt && cmake . && make && make install',
    "\   },
    "\   'autoload': { 'filetypes' : ['c', 'cpp', 'objc', 'objcpp'] },
    "\   'build_commands' : ['cmake', 'make']
    "\}
endif

" Auto completion.
"NeoBundle 'OmniCppComplete' " Ctags auto complete popup.
"NeoBundle 'AutoComplPop'    " auto complete popup.

" C/C++ supported.
if !$DISABLE_YCM && has('nvim')
    if has('win32')
        "NeoBundle '~/.vim/bundle/YouCompleteMe-windows-733de48-x86', {
        "\   'type' : 'nosync'
        "\ }
    else
        " Compile command:
        " git submodule update --init --recursive
        " opy3 install.py --clang-completer
        "NeoBundle 'Valloric/YouCompleteMe'
    endif
endif

" Debugging supported.
if has('nvim')
    " Neovim thin wrapper for GDB, LLDB and PDB.
    " NeoBundle 'sakhnik/nvim-gdb', { 'branch': 'legacy' }
    " NeoBundle 'sakhnik/nvim-gdb', { 'do': './install.sh' }
    " NeoBundle 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }
endif

" Rails supported.
" NeoBundle 'tpope/vim-rails'

" Golang supported.
"NeoBundle 'fatih/vim-go'

" Python supported.
if has('python')
    "NeoBundle 'klen/python-mode'
endif

"if has("netbeans_intg")
    "NeoBundle '~/.vim/bundle/pyclewn-2.0.1', {
    "\   'type' : 'nosync'
    "\ }
"endif

" Quickfix
"NeoBundle 'romainl/vim-qf'  " tame the quickfix window.

