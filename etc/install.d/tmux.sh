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

TPM_URL=https://github.com/tmux-plugins/tpm
TPM_DIR=$HOME/.tmux/plugins/tpm

## Backup the previous tmux config file.
backup_file "$TMUX_CONFIG"

## Remove the previous tmux config file.
remove_file "$TMUX_CONFIG"

## Install Tmux-Plugin-Manager
if [[ -d "$TPM_DIR/.git" ]]; then
    print_warning "Exists $TPM_DIR"
else
    WHICH_GIT=`which git 2> /dev/null`
    if [[ -n "$WHICH_GIT" ]]; then
        "$WHICH_GIT" clone "$TPM_URL" "$TPM_DIR"
    else
        print_warning 'Not found git executable.'
    fi
fi

## Install source-file config.
echo -e "source-file $SRC_TMUX_CONFIG" >> $TMUX_CONFIG
print_information "Write tmux source-file config."

