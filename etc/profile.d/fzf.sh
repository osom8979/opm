#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

FZF_EXAMPLES=$OPM_HOME/etc/fzf/examples
FZF_KEY_BINDINGS=$FZF_EXAMPLES/key-bindings.bash

if [[ -f "$FZF_KEY_BINDINGS" ]]; then
    source "$FZF_KEY_BINDINGS"
fi
