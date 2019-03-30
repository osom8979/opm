#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

PREFIX=/usr/local/tparty

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

