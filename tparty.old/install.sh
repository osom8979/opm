#!/bin/bash

function getScriptDirectory {
    local working=$PWD
    cd "$(dirname "${BASH_SOURCE[0]}")"
    echo $PWD
    cd "$working"
}

if [[ -z $TPARTY_HOME ]]; then
    # Not found TPARTY_HOME variable.
    export TPARTY_HOME=`getScriptDirectory`
fi

# Argument value.
ALWAYS_YES=False

# Argument loop.
ARG_INDEX=1
ARG_SIZE=$#
while [[ $ARG_INDEX -le $ARG_SIZE ]]; do
    current_arg=$1
    case $current_arg in
    -y)
        ALWAYS_YES=True
        ;;
    esac

    let 'ARG_INDEX = ARG_INDEX + 1'
    shift
done

WORKING=$PWD
BIN_DIR=$TPARTY_HOME/bin
INSTALL_DIR=$TPARTY_HOME/library.d
LOCAL_DIR=$TPARTY_HOME/local

export PATH=$BIN_DIR:$LOCAL_DIR/bin:$PATH
export CPATH=$LOCAL_DIR/include:$CPATH
export LIBRARY_PATH=$LOCAL_DIR/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$LOCAL_DIR/lib:$LD_LIBRARY_PATH
#export DYLD_LIBRARY_PATH=$LOCAL_DIR/lib:$DYLD_LIBRARY_PATH

# Create a cache.
CACHE=cache
if [[ ! -f "$CACHE" ]]; then
    ## Warning: Don't use the quoting("...").
    for cursor in $INSTALL_DIR/*.sh; do
        echo ${cursor##*/} >> $CACHE
    done

    echo "Not found cache file."
    echo "Create cache file: $CACHE"
    exit 0
fi

# Check install files.
INSTALL_SCRIPTS=''
for cursor in $(cat $CACHE); do
    current_script="$INSTALL_DIR/$cursor"
    if [[ -f "$current_script" ]]; then
        if [[ "$INSTALL_SCRIPTS" == "" ]]; then
            INSTALL_SCRIPTS="$cursor"
        else
            INSTALL_SCRIPTS="$INSTALL_SCRIPTS,$cursor"
        fi
    fi
done

echo "Install scripts: $INSTALL_SCRIPTS"

# User input.
if [[ "$ALWAYS_YES" != "True" ]]; then
    read -p "Do you want to continue [y/n]? " yn
    case $yn in
    [Yy]*)
        # Continue!!
        ;;
    [Nn]*)
        exit 1
        ;;
    *)
        echo "Please answer Yes or No."
        exit 1
        ;;
    esac
fi

## Warning: Don't use the quoting("...").
for cursor in $(cat $CACHE); do
    current_script="$INSTALL_DIR/$cursor"
    if [[ ! -f "$current_script" ]]; then
        continue
    fi

    echo "Install: $current_script"
    source "$current_script"
    code=$?

    if [[ $code == 0 ]]; then
        echo 'Install success.'
    else
        echo 'Install failure.'
        # Don't use exit command.
        #exit 0
    fi
done

echo 'Done.'

