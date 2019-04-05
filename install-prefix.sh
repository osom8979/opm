#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

if [[ -z $TPARTY_PREFIX ]]; then
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

read -p "Create prefix directory? (y/n) " USER_REPLY
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

if [[ $DO_INSTALL -eq 0 ]]; then
    echo 'Job cancel.'
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


