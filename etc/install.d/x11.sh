#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    print_error 'Not defined OPM_HOME variable.'
    exit 1
fi

DEST=$HOME/.xinitrc
SRC=$OPM_HOME/etc/x11/xinitrc

CONTENT="
source $SRC
"

if [[ -x "$DEST" ]]; then
    echo "The xinitrc file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $DEST" 1>&2
    exit 1
fi

echo "$CONTENT" >> "$DEST"
