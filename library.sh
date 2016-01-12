#!/bin/bash

function getScriptDirectory {
    local working=$PWD
    cd "$(dirname "${BASH_SOURCE[0]}")"
    echo $PWD
    cd "$working"
}

WORKING=$PWD
SCRIPT_PATH=`getScriptDirectory`

INSTALL_DIR=$SCRIPT_PATH/etc/library.d
PREFIX=$HOME/.local

if [[ ! -d "$PREFIX" ]]; then
    mkdir "$PREFIX"
fi

## Warning: Don't use the quoting("...").
for cursor in $INSTALL_DIR/*.sh; do
    echo 'Install:' $cursor
    source $cursor
    code=$?

    if [[ $code == 0 ]]; then
        echo 'Install success.'
    else
        echo 'Install failure.'
    fi
done

echo 'Done.'

