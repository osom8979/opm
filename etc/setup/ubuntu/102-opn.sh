#!/usr/bin/env bash

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
