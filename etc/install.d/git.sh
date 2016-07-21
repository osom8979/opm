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
    mv $GITCONFIG $GITCONFIG.$DATE_FORMAT.backup
fi

## [WARNING] Don't use symbolic link.
## ln -s $SRC_GITCONFIG $GITCONFIG

## Copy gitconfig file.
cp "$SRC_GITCONFIG" "$GITCONFIG"

## Finally, insert user name (Only zer0's).
if [[ "$CURRENT_USER" == "zer0" ]]; then
    echo -e "[user]" >> $GITCONFIG
    echo -e "\tname = zer0" >> $GITCONFIG
    echo -e "\temail = osom8979@gmail.com" >> $GITCONFIG
fi

