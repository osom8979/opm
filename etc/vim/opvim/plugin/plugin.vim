" OPM-VIM PLUGIN AUTOLOAD.

call opvim#Initialize()

command! -nargs=? CMake call opvim#CMake(<f-args>)

