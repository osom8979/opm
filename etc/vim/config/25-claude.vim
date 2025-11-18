let s:plugin_name = 'claude-cursor.vim'
let s:plugin_homepage = 'https://github.com/osom8979/claude-cursor.vim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

let g:claude_cursor_executable = 'opn-claude'
let g:claude_cursor_terminal_width = 80

