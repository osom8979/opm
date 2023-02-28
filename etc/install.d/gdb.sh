#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

SRC=$OPM_HOME/etc/gdb/gdbinit
DEST=$HOME/.gdbinit

CONTENT="
source $SRC
"

if [[ -x "$DEST" ]]; then
    echo "The gdbinit file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $DEST" 1>&2
    exit 1
fi

echo "$CONTENT" >> "$DEST"
