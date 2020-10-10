let s:plugin_name = 'fzf'
let s:plugin_homepage = 'https://github.com/junegunn/fzf'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

noremap <C-P> <ESC>:FZF<CR>

