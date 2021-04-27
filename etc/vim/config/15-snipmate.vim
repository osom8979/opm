let s:plugin_name = 'vim-snipmate'
let s:plugin_homepage = 'https://github.com/garbas/vim-snipmate'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let g:snipMate = { 'snippet_version' : 1 }

