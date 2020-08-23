#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    print_error 'Not defined OPM_HOME variable.'
    exit 1
fi
if [[ $VIA_INSTALLATION_SCRIPT -ne 1 ]]; then
    print_error 'You have to do it through the installation script.'
    exit 1
fi

AUTOMATIC_YES_FLAG=${AUTOMATIC_YES_FLAG:-0}

XMONAD_DIR=$HOME/.xmonad
XMONAD_LIB_DIR=$XMONAD_DIR/lib
XMONAD_LIB_OPM_DIR=$XMONAD_LIB_DIR/Opm
XMONAD_CONFIG=$XMONAD_DIR/xmonad.hs
SRC_XMONAD_CONFIG=$OPM_HOME/etc/xmonad/xmonad.hs
SRC_XMONAD_LIB_OPM_DIR=$OPM_HOME/etc/xmonad/Opm

mkdirs "$XMONAD_DIR"
mkdirs "$XMONAD_LIB_DIR"

## Backup the previous xmonad config file.
backup_file "$XMONAD_CONFIG"

## Remove the previous xmonad config file.
rm -f "$XMONAD_CONFIG"

if [[ ! -e "$XMONAD_LIB_OPM_DIR" ]]; then
    ln -s "$SRC_XMONAD_LIB_OPM_DIR" "$XMONAD_LIB_OPM_DIR"
fi

## Install config file.
cp "$SRC_XMONAD_CONFIG" "$XMONAD_CONFIG"
print_information "Write config file."


