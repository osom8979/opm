#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

NEOBUNDLE_URL=https://github.com/Shougo/neobundle.vim
NEOBUNDLE_DIR=$HOME/.vim/bundle/neobundle.vim

if ! command -v git &> /dev/null; then
    echo "Not found git executable" 1>&2
    exit 1
fi

if [[ -d "$NEOBUNDLE_DIR/.git" ]]; then
    git --work-tree="$NEOBUNDLE_DIR" --git-dir="$NEOBUNDLE_DIR/.git" pull origin master
else
    if [[ ! -d "$NEOBUNDLE_DIR" ]]; then
        mkdir -vp "$NEOBUNDLE_DIR"
    fi
    git clone "$NEOBUNDLE_URL" "$NEOBUNDLE_DIR"
fi
