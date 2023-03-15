#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v opn-npm &> /dev/null; then
    echo "Not found opn-npm command" 1>&2
    exit 1
fi

PACKAGES=(
    neovim
    prettier
    typescript
    yarn
)

opn-npm install -g "${PACKAGES[@]}"
