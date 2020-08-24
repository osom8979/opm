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

LLDBINIT_CONFIG=$HOME/.lldbinit
SRC_LLDBINIT_CONFIG=$OPM_HOME/etc/lldb/lldbinit

## Backup the previous lldb config file.
backup_file "$LLDBINIT_CONFIG"

## Remove the previous lldb config file.
rm -f "$LLDBINIT_CONFIG"

## Install source-file config.
echo -e "command source $SRC_LLDBINIT_CONFIG" >> $LLDBINIT_CONFIG
print_information "Write lldb source config."

