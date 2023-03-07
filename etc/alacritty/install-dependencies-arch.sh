#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v pacman &> /dev/null; then
    echo "Not found pacman command" 1>&2
    exit 1
fi

pacman -S cmake freetype2 fontconfig pkg-config make libxcb libxkbcommon
