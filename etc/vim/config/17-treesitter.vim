let s:plugin_name = 'nvim-treesitter'
let s:plugin_homepage = 'https://github.com/nvim-treesitter/nvim-treesitter'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

" The bundle directory can exist before it is added to 'runtimepath',
" e.g. on the first startup right after NeoBundle clones the plugin.
if empty(globpath(&runtimepath, 'lua/nvim-treesitter/configs.lua'))
    echohl WarningMsg
    echom s:plugin_name.' is installed but not loaded yet.'
    echom 'Please restart nvim.'
    echohl None
    finish
endif

let s:script_dir = expand('<sfile>:p:h')
let s:init_lua_path = s:script_dir.'/17-treesitter.lua'

execute "luafile " . s:init_lua_path
