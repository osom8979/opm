#!/bin/bash

VI_PATH=`which vi`
VIM_PATH=`which vim`

if [[ -f "$VIM_PATH" ]]; then
CSCOPE_EDITOR="$VIM_PATH"
elif [[ -f "$VI_PATH" ]]; then
CSCOPE_EDITOR="$VI_PATH"
fi

export CSCOPE_EDITOR

