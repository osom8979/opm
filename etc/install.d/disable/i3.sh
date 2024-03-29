#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

INSTALL_DIR=$HOME/.i3
DEST=$INSTALL_DIR/config
SRC=$OPM_HOME/etc/i3/config

if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -vp "$INSTALL_DIR"
fi

if [[ -e "$DEST" ]]; then
    echo "The i3 config file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $DEST" 1>&2
    exit 1
fi

ln -s "$SRC" "$DEST"
