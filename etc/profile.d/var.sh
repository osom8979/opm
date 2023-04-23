#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPM_VAR=$OPM_HOME/var
OPM_VAR_BIN=$OPM_VAR/bin

if [[ ! -d "$OPM_VAR_BIN" ]]; then
    echo "Not found '$OPM_VAR_BIN' directory" 1>&2
    mkdir -vp "$OPM_VAR_BIN"
fi

export PATH="$OPM_VAR_BIN:$PATH"
