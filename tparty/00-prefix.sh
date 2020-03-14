#!/usr/bin/env bash

ENABLE_PREFIX_CHECK=0
WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX
check_variable_or_exit USER

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

if [[ -d "$PREFIX" ]]; then
    echo "Exists prefix directory: $PREFIX"
    exit 1
else
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

