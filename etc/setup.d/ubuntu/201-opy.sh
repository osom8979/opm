#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v opy &> /dev/null; then
    echo "Not found opy command" 1>&2
    exit 1
fi

PACKAGES=(
    black
    debugpy
    flake8
    isort
    jedi
    jedi-language-server
    mypy
    neovim
    numpy
    pudb
)

opy -m pip install --upgrade pip
opy -m pip install "${PACKAGES[@]}"
