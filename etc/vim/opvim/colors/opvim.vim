" opvim color scheme

highlight clear
if exists("syntax_on")
  syntax reset
endif

set background=dark
let g:colors_name = "opvim"


if has("gui_running") || (has("termguicolors") && &termguicolors)
  let s:true_color = 1
else
  let s:true_color = 0
endif

if s:true_color || &t_Co >= 88
  let s:low_color = 0
else
  let s:low_color = 1
endif


