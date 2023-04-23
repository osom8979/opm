#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPCODE=${1:-install}
FORCE=${FORCE:-0}
AUTOMATIC_YES=${AUTOMATIC_YES:-0}
VFI_FLAGS=${VFI_FLAGS:--v}

# https://raw.githubusercontent.com/alacritty/alacritty/master/alacritty.yml
SRC=$OPM_HOME/etc/alacritty/alacritty.yml
DEST=$HOME/.alacritty.yml

function install
{
    if [[ $FORCE -eq 0 && ! -f "$SRC" ]]; then
        echo "Not found source file: '$SRC'" 1>&2
        exit 1
    fi

    if [[ $FORCE -eq 0 && -e "$DEST" ]]; then
        echo "The alacritty configuration file already exists" 1>&2
        echo "Delete the file to continue installation" 1>&2
        echo " $DEST" 1>&2
        exit 1
    fi

    {
        echo "## OSOM PACKAGE MANAGER"
        echo "import:"
        echo "  - $SRC"
    } >> "$DEST"
    echo "alacritty installation successful: $DEST"
}

function uninstall
{
    rm "$VFI_FLAGS" "$DEST"
}

if [[ $OPCODE == "install" ]]; then
    install
elif [[ $OPCODE == "uninstall" ]]; then
    uninstall
fi
