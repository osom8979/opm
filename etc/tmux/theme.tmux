#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

function tmux_get
{
    local option=$1
    local default=$2

    local value
    if value="$(tmux show -gqv "$option")"; then
        if [[ -n "$value" ]]; then
            echo "$value"
        fi
    fi

    echo "$default"
}

function tmux_set
{
    local option=$1
    local value=$2
    tmux set-option -gq "$option" "$value"
}

session_icon=""
user_icon=""
time_icon=""
date_icon=""
rarrow=""
larrow=""
upload_speed_icon="󰕒"
download_speed_icon="󰇚"
theme "everforest"
date_format="%F"
time_format="%T"
prefix_highlight_pos="L"

show_upload_speed=1
show_download_speed=1
show_web_reachable=1

TC="#a7c080"

G01=#080808 #232
G02=#121212 #233
G03=#1c1c1c #234
G04=#262626 #235
G05=#303030 #236
G06=#3a3a3a #237
G07=#444444 #238
G08=#4e4e4e #239
G09=#585858 #240
G10=#626262 #241
G11=#6c6c6c #242
G12=#767676 #243

FG="$G10"
BG="$G04"

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_fg "$BG"
tmux_set @prefix_highlight_bg "$FG"
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$BG]$larrow#[bg=$TC]#[fg=$BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$BG]$rarrow"

#     
# Left side of status bar
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$G12"
tmux_set status-left-length 150
user=$(whoami)
LS="#[fg=$G04,bg=$TC,bold] $user_icon $user@#h #[fg=$TC,bg=$G06,nobold]$rarrow#[fg=$TC,bg=$G06] $session_icon #S "
if "$show_upload_speed"; then
    LS="$LS#[fg=$G06,bg=$G05]$rarrow#[fg=$TC,bg=$G05] $upload_speed_icon #{upload_speed} #[fg=$G05,bg=$BG]$rarrow"
else
    LS="$LS#[fg=$G06,bg=$BG]$rarrow"
fi
if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
    LS="$LS#{prefix_highlight}"
fi
tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$G12"
tmux_set status-right-length 150
RS="#[fg=$G06]$larrow#[fg=$TC,bg=$G06] $time_icon $time_format #[fg=$TC,bg=$G06]$larrow#[fg=$G04,bg=$TC] $date_icon $date_format "
if "$show_download_speed"; then
    RS="#[fg=$G05,bg=$BG]$larrow#[fg=$TC,bg=$G05] $download_speed_icon #{download_speed} $RS"
fi
if "$show_web_reachable"; then
    RS=" #{web_reachable_status} $RS"
fi
if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi
tmux_set status-right "$RS"

# Window status format
tmux_set window-status-format         "#[fg=$BG,bg=$G06]$rarrow#[fg=$TC,bg=$G06] #I:#W#F #[fg=$G06,bg=$BG]$rarrow"
tmux_set window-status-current-format "#[fg=$BG,bg=$TC]$rarrow#[fg=$BG,bg=$TC,bold] #I:#W#F #[fg=$TC,bg=$BG,nobold]$rarrow"

# Window status style
tmux_set window-status-style          "fg=$TC,bg=$BG,none"
tmux_set window-status-last-style     "fg=$TC,bg=$BG,bold"
tmux_set window-status-activity-style "fg=$TC,bg=$BG,bold"

# Window separator
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=$G07,bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$G07"
tmux_set display-panes-active-colour "$TC"

# Clock mode
tmux_set clock-mode-colour "$TC"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$TC,bg=$BG"

# Command message
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$FG"

