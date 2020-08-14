NeoBundle 'wesleyche/SrcExpl'           " displaying prototype (Conflict from the ctags.vim).
NeoBundle 'matchparenpp'                " blink match brace. (Error!)
NeoBundle 'edkolev/promptline.vim'      " generate a fast shell prompt.
NeoBundle 'tpope/vim-surround'          " quoting/parenthesizing made simple.
NeoBundle 'zakj/vim-showmarks'          " show mark list bar.
NeoBundle 'vhdirk/vim-cmake'            " cmake
NeoBundle 'nanotech/jellybeans.vim'     " Themes
NeoBundle 'OmniCppComplete'             " ctags auto complete popup.
NeoBundle 'AutoComplPop'                " auto complete popup.
NeoBundle 'klen/python-mode'            " python supported.
NeoBundle 'tpope/vim-rails'             " rails supported.
NeoBundle 'fatih/vim-go'                " golang supported.
NeoBundle 'romainl/vim-qf'              " tame the quickfix window.
NeoBundle 'scrooloose/syntastic'        " syntax checking hacks for vim.
NeoBundle 'ctags.vim'                   " ctags plugin (Conflict from the SrcExpl).
NeoBundle 'cscope.vim'                  " cscope plugin.
NeoBundle 'simnalamburt/vim-mundo'      " undo tree visualizer

if has('nvim')
    NeoBundle 'arakashic/chromatica.nvim'  " clang based syntax highlighting for neovim.
    NeoBundle 'bbchung/Clamp'              " neovim plugin to highlight c-family code.
else
    " For now, at least, color_coded is not supporting neovim.
    NeoBundleLazy 'jeaye/color_coded', {
        \   'build': {
        \       'unix': 'rm -f CMakeCache.txt && cmake . && make && make install',
        \   },
        \   'autoload': { 'filetypes' : ['c', 'cpp', 'objc', 'objcpp'] },
        \   'build_commands' : ['cmake', 'make']
        \}
endif

if !$DISABLE_YCM && has('nvim')
    if has('win32')
        NeoBundle '~/.vim/bundle/YouCompleteMe-windows-733de48-x86', {
            \   'type' : 'nosync'
            \}
    else
        " Compile command:
        " git submodule update --init --recursive
        " opy3 install.py --clang-completer
        NeoBundle 'Valloric/YouCompleteMe'
    endif
endif

if has('nvim')
    " Neovim thin wrapper for GDB, LLDB and PDB.
    NeoBundle 'sakhnik/nvim-gdb', {
        \   'do': ':!./install.sh \| UpdateRemotePlugins'
        \}
endif

if has("netbeans_intg")
    NeoBundle '~/.vim/bundle/pyclewn-2.0.1', {
        \  'type' : 'nosync'
        \}
endif

