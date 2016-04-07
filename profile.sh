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
OPM_PYTHON=$OPM_HOME/python

## Bash setting.
if [[ -z $CLICOLOR ]]; then
    export CLICOLOR=1
fi
if [[ -z $LSCOLORS ]]; then
    export LSCOLORS=ExFxBxDxCxegedabagacad
fi

## General setting.
export PATH=$OPM_BIN:$PATH
export LC_COLLATE="ko_KR.UTF-8"
export EDITOR=vi

## Python setting.
export PYTHONPATH=$OPM_PYTHON:$PYTHONPATH

## Extension.
OPM_PROFILE_DIR=$OPM_HOME/etc/profile.d

## Warning: Don't use the quoting("...").
for cursor in $OPM_PROFILE_DIR/*.sh; do
    . $cursor
done

