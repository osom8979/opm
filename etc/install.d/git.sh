#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

GITCONFIG=$HOME/.gitconfig
SRC_GITCONFIG=$OPM_HOME/etc/git/gitconfig

DATE_FORMAT=`date +%Y%m%d_%H%M%S`

## Backup.
if [[ -f $GITCONFIG ]]; then
    mv $GITCONFIG $GITCONFIG.$DATE_FORMAT.backup
fi

## Create a symbolic link.
ln -s $SRC_GITCONFIG $GITCONFIG

