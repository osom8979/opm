#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

DEST=$HOME/.lldbinit
SRC=$OPM_HOME/etc/lldb/lldbinit

CONTENT="
command source $SRC
"

if [[ -x "$DEST" ]]; then
    echo "The lldbinit file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $DEST" 1>&2
    exit 1
fi

echo "$CONTENT" >> "$DEST"
