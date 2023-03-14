#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

SRC=$OPM_HOME/etc/git/gitconfig
DEST=$HOME/.gitconfig

if [[ -e "$DEST" ]]; then
    echo "The gitconfig file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $DEST" 1>&2
    exit 1
fi

read -r -p "User name? " USER_NAME
read -r -p "User email? " USER_EMAIL

CONTENT="
[include]
    path = $SRC

[user]
    name = $USER_NAME
    email = $USER_EMAIL
"

echo "$CONTENT" >> "$DEST"
