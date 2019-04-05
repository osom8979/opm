#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

function help_and_exit {
    echo "Usage: ${BASH_SOURCE[0]} {options}"
    echo " -y  Automatic yes to prompts."
    echo " -h  Show this help message."
    exit 0
}

while getopts "y:h" opt
do
    case $opt in
    y)
        USER_REPLY=1
        ;;
    h)
        help_and_exit
        ;;
    *)
        help_and_exit
        ;;
    esac
done

if [[ -z $TPARTY_HOME ]]; then
PREFIX=/usr/local/tparty
else
PREFIX=$TPARTY_PREFIX
fi

if [[ -d $PREFIX ]]; then
    if [[ -w $PREFIX ]]; then
        echo "The PREFIX directory exists: ${PREFIX}"
    else
        echo "A non-writable PREFIX directory exists: ${PREFIX}"
    fi
    exit 1
elif [[ -e $PREFIX ]]; then
    echo "PREFIX exists and is not a directory: ${PREFIX}"
    exit 1
fi

echo "PREFIX directory: ${PREFIX}"

if [[ USER_REPLY -eq 1 ]]; then
    read -p "Create prefix directory (y/n)?" USER_REPLY
    case "$USER_REPLY" in
    y|Y)
        DO_INSTALL=1
        ;;
    n|N)
        DO_INSTALL=0
        ;;
    *)
        DO_INSTALL=0;
        echo 'Invalid answer.'
        ;;
    esac
fi

if [[ $DO_INSTALL -eq 0 ]]; then
    echo 'Cancel job.'
    exit 1
fi

if [[ ! -d "$PREFIX" ]]; then
    mkdir -p "$PREFIX"
fi

ORIGINAL_USER=$SUDO_USER
if [[ -z $ORIGINAL_USER ]]; then
ORIGINAL_USER=$USER
fi

ORIGINAL_GID=$SUDO_GID
if [[ -z $ORIGINAL_GID ]]; then
ORIGINAL_GID=`id -g`
fi

chown $ORIGINAL_USER "$PREFIX"
chgrp $ORIGINAL_GID "$PREFIX"

echo "Created $ORIGINAL_USER's PREFIX directory: $PREFIX"


