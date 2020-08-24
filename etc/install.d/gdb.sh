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

GDBINIT_CONFIG=$HOME/.gdbinit
SRC_GDBINIT_CONFIG=$OPM_HOME/etc/gdb/gdbinit

## Backup the previous gdb config file.
backup_file "$GDBINIT_CONFIG"

## Remove the previous gdb config file.
rm -f "$GDBINIT_CONFIG"

## Install source-file config.
echo -e "source $SRC_GDBINIT_CONFIG" >> $GDBINIT_CONFIG
print_information "Write gdb source config."

