#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v cargo &> /dev/null; then
    opm-init-opr

    if ! command -v cargo &> /dev/null; then
        echo "Not found cargo command" 1>&2
        exit 1
    fi
fi

PACKAGES=(
    alacritty
)

for pkg in "${PACKAGES[@]}"; do
    cargo install "$pkg"
done
