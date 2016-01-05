#!/bin/bash

function getScriptDirectory {
    local src=${BASH_SOURCE[0]}
    local dir=$(dirname "$src")
    local prev=$PWD
    cd "$dir"
    echo $PWD
    cd "$prev"
}

WORKING=$PWD
SCRIPT_PATH=`getScriptDirectory`

INSTALL_DIR=$SCRIPT_PATH/etc/library.d
PREFIX=$HOME/.local

if [[ ! -d "$PREFIX" ]]; then
    mkdir "$PREFIX"
fi

for cursor in "$INSTALL_DIR/*.sh"; do
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

