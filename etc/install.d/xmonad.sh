#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

XMONAD_DIR=$HOME/.xmonad
XMONAD_LIB_DIR=$XMONAD_DIR/lib
XMONAD_LIB_OPM_DIR=$XMONAD_LIB_DIR/Opm
XMONAD_CONFIG=$XMONAD_DIR/xmonad.hs

SRC_CONFIG=$OPM_HOME/etc/xmonad/xmonad.hs
SRC_OPM_DIR=$OPM_HOME/etc/xmonad/lib/Opm

if [[ -e "$XMONAD_CONFIG" ]]; then
    echo "The xmonad config file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $XMONAD_CONFIG" 1>&2
    exit 1
fi
if [[ -e "$XMONAD_LIB_OPM_DIR" ]]; then
    echo "The xmonad opm directory already exists" 1>&2
    echo "Delete the directory to continue installation" 1>&2
    echo " $XMONAD_LIB_OPM_DIR" 1>&2
    exit 1
fi

if [[ ! -d "$XMONAD_DIR" ]]; then
    mkdir -vp "$XMONAD_DIR"
fi
if [[ ! -d "$XMONAD_LIB_DIR" ]]; then
    mkdir -vp "$XMONAD_LIB_DIR"
fi

if [[ ! -e "$XMONAD_LIB_OPM_DIR" ]]; then
    ln -s "$SRC_OPM_DIR" "$XMONAD_LIB_OPM_DIR"
fi

cp -v "$SRC_CONFIG" "$XMONAD_CONFIG"
