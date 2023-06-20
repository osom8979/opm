finish

let s:plugin_name = 'nvim-treesitter'
let s:plugin_homepage = 'https://github.com/nvim-treesitter/nvim-treesitter'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let s:script_dir = expand('<sfile>:p:h')
let s:init_lua_path = s:script_dir.'/17-treesitter.lua'

if 0
    echom "Experimental feature of Neovim"
    execute "luafile " . s:init_lua_path
endif
