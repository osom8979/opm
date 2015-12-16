#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

CLEAN_FLAG=false

for arg in $@; do
    case $arg in
    --clean)
        CLEAN_FLAG=true
        ;;
    esac
done

GITCONFIG=$HOME/.gitconfig
SRC_GITCONFIG=$OPM_HOME/etc/git/gitconfig

DATE_FORMAT=`date +%Y%m%d_%H-%M-%S`

if [[ $CLEAN_FLAG == true ]]; then
    rm $GITCONFIG
    return
fi

## Backup.
if [[ -f $GITCONFIG ]]; then
    mv $GITCONFIG $GITCONFIG.$DATE_FORMAT.backup
fi

## Create a symbolic link.
ln -s $SRC_GITCONFIG $GITCONFIG

