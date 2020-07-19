#!/usr/bin/env bash

VI_PATH=`which vi 2> /dev/null`
VIM_PATH=`which vim 2> /dev/null`

if [[ -f "$VIM_PATH" ]]; then
CSCOPE_EDITOR="$VIM_PATH"
elif [[ -f "$VI_PATH" ]]; then
CSCOPE_EDITOR="$VI_PATH"
fi

export CSCOPE_EDITOR

