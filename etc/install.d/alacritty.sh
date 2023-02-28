#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

# https://raw.githubusercontent.com/alacritty/alacritty/master/alacritty.yml
SRC=$OPM_HOME/etc/alacritty/alacritty.yml
DEST=$HOME/.alacritty.yml

CONTENT="
import:
  - $SRC
"

if [[ -x "$DEST" ]]; then
    echo "The alacritty configuration file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $DEST" 1>&2
    exit 1
fi

echo "$CONTENT" >> "$DEST"
