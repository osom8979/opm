let s:plugin_name = 'claudecode.nvim'
let s:plugin_homepage = 'https://github.com/coder/claudecode.nvim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let s:script_dir = expand('<sfile>:p:h')
let s:init_lua_path = s:script_dir.'/26-claudecode.lua'

execute "luafile " . s:init_lua_path

" Note: `<leader>a` is used by coc code actions.
nnoremap <silent> <leader>kc :ClaudeCode<CR>
nnoremap <silent> <leader>kf :ClaudeCodeFocus<CR>
xnoremap <silent> <leader>ks :ClaudeCodeSend<CR>
nnoremap <silent> <leader>kb :ClaudeCodeAdd %<CR>
nnoremap <silent> <leader>ka :ClaudeCodeDiffAccept<CR>
nnoremap <silent> <leader>kd :ClaudeCodeDiffDeny<CR>
