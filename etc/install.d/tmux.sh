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

TMUX_CONFIG=$HOME/.tmux.conf
SRC_TMUX_CONFIG=$OPM_HOME/etc/tmux/config

## Backup the previous tmux config file.
backup_file "$TMUX_CONFIG"

## Remove the previous tmux config file.
rm -f "$TMUX_CONFIG"

## Install source-file config.
echo -e "source-file $SRC_TMUX_CONFIG" >> $TMUX_CONFIG
print_information "Write tmux source-file config."

