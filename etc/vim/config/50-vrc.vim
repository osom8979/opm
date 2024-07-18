let s:plugin_name = 'vim-rest-console'
let s:plugin_homepage = 'https://github.com/diepm/vim-rest-console'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

" let g:vrc_connect_timeout = 10
" let g:vrc_cookie_jar = '/path/to/cookie'
" let g:vrc_follow_redirects = 1
" let g:vrc_include_response_header = 1
" let g:vrc_max_time = 60
" let g:vrc_resolve_to_ipv4 = 1
" let g:vrc_ssl_secure = 1

" let g:vrc_curl_opts = {
" \ '--connect-timeout' : 10,
" \ '-b': '/path/to/cookie',
" \ '-c': '/path/to/cookie',
" \ '-L': '',
" \ '-i': '',
" \ '--max-time': 60,
" \ '--ipv4': '',
" \ '-k': '',
" \}

