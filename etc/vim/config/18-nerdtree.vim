let s:plugin_name = 'nerdtree'
let s:plugin_homepage = 'https://github.com/preservim/nerdtree'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

" NERDTree
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 42
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = [
    \   '^\.$',
    \   '^\.\.$',
    \   '^\~$',
    \   '.*\.[oO]$',
    \   '.*\.[eE][xX][eE]$',
    \   '.*\.pyc$'
    \]

