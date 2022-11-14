#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if [[ -z $OPM_HOME ]]; then
export OPM_HOME="$ROOT_DIR"
fi

## Default shell configurations.
export PATH=$OPM_HOME/bin:$PATH

# Select Graphic Rendition
function sgr
{
    echo -n "\e[${1}m"
}

function sgr_reset
{
    sgr 0
}

function sgr_bold
{
    sgr 1
}

function sgr_fg_black
{
    sgr 30
}

function sgr_fg_green
{
    sgr 32
}

function sgr_fg_bright_magenta
{
    sgr 95
}

function sgr_fg_bright_cyan
{
    sgr 96
}

function sgr_bg_bright_yellow
{
    sgr 103
}

function ps_timestamp
{
    echo -n "$(sgr_bold)[\t]$(sgr_reset)"
}

function ps_user_host
{
    echo -n "$(sgr_bold)$(sgr_fg_green)\u@\h$(sgr_reset)"
}

function ps_path
{
    echo -n "$(sgr_bold)$(sgr_fg_bright_cyan)\w$(sgr_reset)"
}

function ps_newline
{
    echo -n "\n"
}

function ps_has_root
{
    echo -n "\\$"
}

function git_branch_name
{
    local name
    name=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ $? -eq 0 ]]; then
        echo -n "(${name})"
    fi
}

function ps_git_branch_name
{
    echo -n "$(sgr_bold)$(sgr_fg_bright_magenta)\$(git_branch_name)$(sgr_reset)"
}

if [[ "${SHELL##*/}" == "bash" ]]; then
export PS1="$(ps_timestamp) $(ps_user_host):$(ps_path) $(ps_git_branch_name)$(ps_newline)$(ps_has_root) "
fi

if [[ -z $CLICOLOR ]]; then
export CLICOLOR=1
fi

if [[ -z $LSCOLORS ]]; then
export LSCOLORS=ExFxBxDxCxegedabagacad
fi

#if [[ -z $LC_COLLATE ]]; then
#export LC_COLLATE=ko_KR.UTF-8
#fi

WHICH_NVIM=`which nvim 2> /dev/null`
WHICH_VIM=`which vim 2> /dev/null`
WHICH_VI=`which vi 2> /dev/null`

if [[ -z "$EDITOR" ]]; then
    if [[ -n "$WHICH_NVIM" ]]; then
        export EDITOR=$WHICH_NVIM
    elif [[ -n "$WHICH_VIM" ]]; then
        export EDITOR=$WHICH_VIM
    elif [[ -n "$WHICH_VI" ]]; then
        export EDITOR=$WHICH_VI
    fi
fi

if [[ -z $LC_ALL ]]; then
export LC_ALL=en_US.UTF-8
fi

if [[ -z $LANG ]]; then
export LANG=en_US.UTF-8
fi

## Warning: Don't use the quoting("...").
for cursor in $OPM_HOME/etc/profile.d/*.sh; do
    . $cursor
done

