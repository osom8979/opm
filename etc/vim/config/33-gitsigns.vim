let s:plugin_name = 'gitsigns.nvim'
let s:plugin_homepage = 'https://github.com/lewis6991/gitsigns.nvim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let s:script_dir = expand('<sfile>:p:h')
let s:init_lua_path = s:script_dir.'/33-gitsigns.lua'

execute "luafile " . s:init_lua_path
