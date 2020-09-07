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

XINITRC_CONFIG=$HOME/.xinitrc
SRC_XINITRC_CONFIG=$OPM_HOME/etc/x11/xinitrc

## Backup the previous x11 config file.
backup_file "$XINITRC_CONFIG"

## Remove the previous x11 config file.
remove_file "$XINITRC_CONFIG"

## Install source config.
echo -e "source $SRC_XINITRC_CONFIG" >> $XINITRC_CONFIG
print_information "Write xinitrc source config."


