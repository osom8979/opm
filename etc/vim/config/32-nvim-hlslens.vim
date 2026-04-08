let s:plugin_name = 'nvim-hlslens'
let s:plugin_homepage = 'https://github.com/kevinhwang91/nvim-hlslens'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let s:script_dir = expand('<sfile>:p:h')
let s:init_lua_path = s:script_dir.'/32-nvim-hlslens.lua'

execute "luafile " . s:init_lua_path
