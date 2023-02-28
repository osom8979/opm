#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

WHICH_NVIM=$(command -v nvim &> /dev/null)
WHICH_VIM=$(command -v vim &> /dev/null)
WHICH_VI=$(command -v vi &> /dev/null)

if [[ -z "$EDITOR" ]]; then
    if [[ -n "$WHICH_NVIM" ]]; then
        export EDITOR=$WHICH_NVIM
    elif [[ -n "$WHICH_VIM" ]]; then
        export EDITOR=$WHICH_VIM
    elif [[ -n "$WHICH_VI" ]]; then
        export EDITOR=$WHICH_VI
    fi
fi

if [[ -n "$EDITOR" ]]; then
    export CSCOPE_EDITOR=$EDITOR
fi
