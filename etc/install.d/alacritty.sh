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

ALACRITTY_CONFIG=$HOME/.alacritty.yml
SRC_ALACRITTY_CONFIG=$OPM_HOME/etc/alacritty/alacritty.yml

## Backup the previous alacritty config file.
backup_file "$ALACRITTY_CONFIG"

## Remove the previous alacritty config file.
rm -f "$ALACRITTY_CONFIG"

## Install config file.
symbolic_link "$SRC_ALACRITTY_CONFIG" "$ALACRITTY_CONFIG"
print_information "Write config file."

