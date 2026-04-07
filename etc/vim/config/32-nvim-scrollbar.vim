let s:plugin_name = 'nvim-scrollbar'
let s:plugin_homepage = 'https://github.com/petertriho/nvim-scrollbar'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let s:script_dir = expand('<sfile>:p:h')
let s:init_lua_path = s:script_dir.'/32-nvim-scrollbar.lua'

execute "luafile " . s:init_lua_path
