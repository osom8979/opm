#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v opn-yarn &> /dev/null; then
    echo "Not found opn-yarn executable" 1>&2
    exit 1
fi

# coc.vim build
COC_DIR=$HOME/.vim/bundle/coc.nvim

opn-yarn --cwd "$COC_DIR" install
opn-yarn --cwd "$COC_DIR" build
