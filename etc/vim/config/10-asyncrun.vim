let s:plugin_name = 'asyncrun.vim'
let s:plugin_homepage = 'https://github.com/skywind3000/asyncrun.vim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

if !exists('g:opm_default_asyncrun_key')
    let g:opm_default_asyncrun_key = '<leader><leader>`'
endif

let g:asyncrun_rootmarks = ['.git', '.svn', '.root', '.project', '.hg']

" -----------
" Key mapping
" -----------

silent execute 'noremap '.g:opm_default_asyncrun_key.' <ESC>:AsyncRun '

