#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    return 0
fi

export PATH="$HOME/.cargo/bin:$PATH"
