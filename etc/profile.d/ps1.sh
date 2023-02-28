#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

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

function sgr_fg_red
{
    sgr 31
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
    # shellcheck disable=SC2028
    echo -n "$(sgr_bold)[\t]$(sgr_reset)"
}

function prev_error
{
    local code=$?
    if [[ $code -ne 0 ]]; then
        echo -n "E$code "
    fi
}

function ps_prev_error
{
    echo -n "$(sgr_bold)$(sgr_fg_red)\$(prev_error)$(sgr_reset)"
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
    # shellcheck disable=SC2028
    echo -n "\n"
}

function ps_has_root
{
    echo -n "\\$"
}

function git_branch_name
{
    local name
    if name=$(git symbolic-ref --short HEAD 2> /dev/null); then
        echo -n "(${name})"
    fi
}

function ps_git_branch_name
{
    echo -n "$(sgr_bold)$(sgr_fg_bright_magenta)\$(git_branch_name)$(sgr_reset)"
}

function ps_space
{
    echo -n " "
}

if [[ "${SHELL##*/}" == "bash" ]]; then
    BUF="$(ps_prev_error)$(ps_timestamp)"
    BUF="$BUF$(ps_space)$(ps_user_host):$(ps_path)"
    BUF="$BUF$(ps_space)$(ps_git_branch_name)$(ps_newline)$(ps_has_root)"
    BUF="$BUF$(ps_space)"
fi

if [[ -n $PS1 && -n $BUF ]]; then
    export PS1=$BUF
fi
