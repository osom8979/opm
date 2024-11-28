#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if command -v exa &> /dev/null; then
    alias ll="exa --icons --long"
    alias lla="exa --icons --long --all"
fi
