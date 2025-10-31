#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if [[ -d "$HOME/.go" ]]; then
    export GOROOT="$HOME/.go"
    export PATH="$GOROOT/bin:$PATH"
fi
