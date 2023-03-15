#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v opy-pip &> /dev/null; then
    echo "Not found opy-pip command" 1>&2
    exit 1
fi

PACKAGES=(
    neovim
    numpy
)

opy-pip install --upgrade pip
opy-pip install "${PACKAGES[@]}"
