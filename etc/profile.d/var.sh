#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPM_VAR=$OPM_HOME/var
OPM_VAR_BIN=$OPM_VAR/bin

if [[ ! -d "$OPM_VAR_BIN" ]]; then
    mkdir -p "$OPM_VAR_BIN"
fi

export PATH="$PATH:$OPM_VAR_BIN"
