let s:plugin_name = 'asynctasks.vim'
let s:plugin_homepage = 'https://github.com/skywind3000/asynctasks.vim'
if !neobundle#is_installed(s:plugin_name)
    echohl WarningMsg
    echom s:plugin_name.' is not installed.'
    echom 'Please check the homepage: '.s:plugin_homepage
    echohl None
    finish
endif

function! s:EditTasksForDefaultCppProject()
    silent execute ':edit .tasks'
    if filereadable('.tasks')
        return
    endif

    for content in readfile(g:opm_vim_script_dir . '/template/tasks/default-cpp.tasks')
        call append(line('$'), content)
    endfor
endfunction

" ---------------
" Command mapping
" ---------------

function! OpmEditTasksForDefaultCppProject()
    call s:EditTasksForDefaultCppProject()
endfunction

