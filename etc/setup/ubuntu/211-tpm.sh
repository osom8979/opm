#!/usr/bin/env bash

if ! command -v git &> /dev/null; then
    echo "not found git executable" 1>&2
    exit 1
fi

URL=https://github.com/tmux-plugins/tpm
DEST=$HOME/.tmux/plugins/tpm

if [[ -d "$DEST/.git" ]]; then
    git --work-tree="$DEST" --git-dir="$DEST/.git" pull origin master
else
    if [[ ! -d "$DEST" ]]; then
        mkdir -vp "$DEST"
    fi
    git clone "$URL" "$DEST"
fi
