" CMake helper.

function! s:EditCMakeListsForDefaultCppProject()
    silent execute ':edit CMakeLists.txt'
    if filereadable('CMakeLists.txt')
        return
    endif

    for content in readfile(g:opm_vim_script_dir . '/template/cmake/default-cpp.cmake')
        call append(line('$'), content)
    endfor
endfunction

" ---------------
" Command mapping
" ---------------

function! OpmEditCMakeListsForDefaultCppProject()
    call s:EditCMakeListsForDefaultCppProject()
endfunction

