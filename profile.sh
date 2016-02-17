#!/bin/bash

function getScriptDirectory {
    local working=$PWD
    cd "$(dirname "${BASH_SOURCE[0]}")"
    echo $PWD
    cd "$working"
}

if [[ -z $OPM_HOME ]]; then
    # Not found OPM_HOME variable.
    export OPM_HOME=`getScriptDirectory`
fi

OPM_BIN=$OPM_HOME/bin
OPM_INC=$OPM_HOME/include
OPM_LIB=$OPM_HOME/lib
OPM_TMP=$OPM_HOME/tmp
OPM_PYTHON=$OPM_HOME/python

OPM_LOCAL=$OPM_HOME/local
OPM_LOCAL_BIN=$OPM_LOCAL/bin
OPM_LOCAL_INC=$OPM_LOCAL/include
OPM_LOCAL_LIB=$OPM_LOCAL/lib


## Bash setting.
if [[ -z $CLICOLOR ]]; then
    export CLICOLOR=1
fi
if [[ -z $LSCOLORS ]]; then
    export LSCOLORS=ExFxBxDxCxegedabagacad
fi

## General setting.
export PATH=$OPM_BIN:$OPM_LOCAL_BIN:$PATH
export EDITOR=vi

export LC_COLLATE="ko_KR.UTF-8"

## Python setting.
export PYTHONPATH=$OPM_PYTHON:$PYTHONPATH

## GCC setting.
export CPATH=$OPM_INC:$OPM_LOCAL_INC:$CPATH
export LIBRARY_PATH=$LIBRARY_PATH:$OPM_LIB:$OPM_LOCAL_LIB
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OPM_LIB:$OPM_LOCAL_LIB
export DYLD_LIBRARY_PATH=$DYLD_LD_LIBRARY_PATH:$OPM_LIB:$OPM_LOCAL_LIB

## Pkg-config setting.
export PKG_CONFIG_PATH=$OPM_LOCAL_LIB/pkgconfig:$PKG_CONFIG_PATH

## Extension.
OPM_PROFILE_DIR=$OPM_HOME/etc/profile.d

## Warning: Don't use the quoting("...").
for cursor in $OPM_PROFILE_DIR/*.sh; do
    . $cursor
done

## OPM last setting.
export OPM_SETUP=1

