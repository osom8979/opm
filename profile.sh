#!/bin/bash

function getScriptDirectory {
    local src=${BASH_SOURCE[0]}
    local dir=$(dirname "$src")
    local prev=$PWD
    cd "$dir"
    echo $PWD
    cd "$prev"
}

if [[ -z $OPM_HOME ]]; then
    # Not found OPM_HOME variable.
    OPM_HOME=`getScriptDirectory`
fi

export OPM_BIN=$OPM_HOME/bin
export OPM_INC=$OPM_HOME/include
export OPM_LIB=$OPM_HOME/lib
export OPM_TMP=$OPM_HOME/tmp
export OPM_PYTHON=$OPM_HOME/python

export OPM_LOCAL=$OPM_HOME/local
export OPM_LOCAL_BIN=$OPM_LOCAL/bin
export OPM_LOCAL_INC=$OPM_LOCAL/include
export OPM_LOCAL_LIB=$OPM_LOCAL/lib

## Bash setting.
if [[ -z $CLICOLOR ]]; then
    export CLICOLOR=1
fi
if [[ -z $LSCOLORS ]]; then
    export LSCOLORS=ExFxBxDxCxegedabagacad
fi

## General setting.
export PATH=$OPM_BIN:$OPM_LOCAL_BIN:$PATH

## Python setting.
export PYTHONPATH=$OPM_PYTHON:$PYTHONPATH

## GCC setting.
export CPATH=$OPM_INC:$OPM_LOCAL_INC:$CPATH
export LIBRARY_PATH=$OPM_LIB:$OPM_LOCAL_LIB:$LIBRARY_PATH
export LD_LIBRARY_PATH=$OPM_LIB:$OPM_LOCAL_LIB:$LD_LIBRARY_PATH

## Extension.
OPM_ETC_PROFILE_DIR=$OPM_HOME/etc/profile.d

## Warning: Don't use the quoting("...").
for cursor in $OPM_ETC_PROFILE_DIR/*.sh; do
    . $cursor
done

## OPM last setting.
export OPM_SETUP_COMPLETE=1

