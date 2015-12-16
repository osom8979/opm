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

OPM_BIN=$OPM_HOME/bin
OPM_INC=$OPM_HOME/include
OPM_LIB=$OPM_HOME/lib
OPM_PYTHON=$OPM_HOME/python

## Bash setting.
if [[ -z $CLICOLOR ]]; then
    export CLICOLOR=1
fi
if [[ -z $LSCOLORS ]]; then
    export LSCOLORS=ExFxBxDxCxegedabagacad
fi

## General setting.
export PATH=$OPM_HOME/bin:$PATH

## Python setting.
export PYTHONPATH=$OPM_BIN:$OPM_PYTHON:$PYTHONPATH

## GCC setting.
export CPATH=$OPM_INC:$CPATH
export LIBRARY_PATH=$OPM_LIB:$LIBRARY_PATH
export LD_LIBRARY_PATH=$OPM_LIB:$LD_LIBRARY_PATH

