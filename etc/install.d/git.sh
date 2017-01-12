#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

GITCONFIG=$HOME/.gitconfig
SRC_GITCONFIG=$OPM_HOME/etc/git/gitconfig
CURRENT_USER=`whoami`

DATE_FORMAT=`date +%Y%m%d_%H%M%S`

## Backup.
if [[ -f $GITCONFIG ]]; then
    cp $GITCONFIG $GITCONFIG.$DATE_FORMAT.backup
fi

## Finally, insert user name (Only zer0's).
if [[ "$CURRENT_USER" == "zer0" ]]; then
    echo -e "[user]"                        >> $GITCONFIG
    echo -e "\tname = zer0"                 >> $GITCONFIG
    echo -e "\temail = osom8979@gmail.com"  >> $GITCONFIG
    echo -e "[include]"                     >> $GITCONFIG
    echo -e "\tpath = $SRC_GITCONFIG"       >> $GITCONFIG
fi

