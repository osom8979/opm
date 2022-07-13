let s:plugin_name = 'jellybeans.vim'
let s:plugin_homepage = 'https://github.com/nanotech/jellybeans.vim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let g:jellybeans_use_lowcolor_black = 0
let g:jellybeans_use_gui_italics = 1
let g:jellybeans_use_term_italics = 0
let g:jellybeans_overrides =
            \{
            \   "Statement": {
            \       "guifg": "cc7832",
            \       "guibg": "",
            \       "attr": "bold",
            \       "ctermfg": "Yellow,",
            \       "ctermbg": "",
            \   },
            \}

" colorscheme jellybeans

