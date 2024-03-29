#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v update-locale &> /dev/null; then
    echo "Not found update-locale command" 1>&2
    exit 1
fi

if grep -q -E 'LC_COLLATE=' /etc/default/locale; then
    echo "LC_COLLATE already exists" 1>&2
    exit 1
fi

DEFAULT_COLLATE=ko_KR.UTF-8
read -r -e -i "$DEFAULT_COLLATE" \
    -p "Please enter the LC_COLLATE " \
    COLLATE

update-locale "LC_COLLATE=$COLLATE"
