#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPCODE=${1:-install}
FORCE=${FORCE:-0}
AUTOMATIC_YES=${AUTOMATIC_YES:-0}
IFS=" " read -r -a VFI_FLAGS <<< "${VFI_FLAGS:--v}"

SRC=$OPM_HOME/etc/gdb/gdbinit
DEST=$HOME/.gdbinit

function install
{
    if [[ $FORCE -eq 0 && ! -f "$SRC" ]]; then
        echo "Not found source file: '$SRC'" 1>&2
        exit 1
    fi

    if [[ $FORCE -eq 0 && -e "$DEST" ]]; then
        echo "The gdbinit file already exists" 1>&2
        echo "Delete the file to continue installation" 1>&2
        echo " $DEST" 1>&2
        exit 1
    fi

    echo "Install file: '$DEST'"
    {
        echo "## OSOM PACKAGE MANAGER"
        echo "source $SRC"
    } >> "$DEST"
    echo "gdbinit installation successful: $DEST"
}

function uninstall
{
    rm "${VFI_FLAGS[@]}" "$DEST"
}

if [[ $OPCODE == "install" ]]; then
    install
elif [[ $OPCODE == "uninstall" ]]; then
    uninstall
fi
