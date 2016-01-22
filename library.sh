#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

WORKING=$PWD
INSTALL_DIR=$OPM_HOME/etc/library.d

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

