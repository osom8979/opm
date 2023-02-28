#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

TPM_URL=https://github.com/tmux-plugins/tpm
TPM_DIR=$HOME/.tmux/plugins/tpm

if ! command -v git &> /dev/null; then
    echo "Not found git executable" 1>&2
    exit 1
fi

if [[ -d "$TPM_DIR/.git" ]]; then
    git --work-tree="$TPM_DIR" --git-dir="$TPM_DIR/.git" pull origin master
else
    if [[ ! -d "$TPM_DIR" ]]; then
        mkdir -vp "$TPM_DIR"
    fi
    git clone "$TPM_URL" "$TPM_DIR"
fi
