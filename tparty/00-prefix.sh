#!/usr/bin/env bash

ENABLE_PREFIX_CHECK=0
WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

if [[ -d $PREFIX ]]; then
    if [[ -w $PREFIX ]]; then
        print_verbose "The PREFIX directory exists: ${PREFIX}"
        exit 0
    else
        print_error "A non-writable PREFIX directory exists: ${PREFIX}"
        exit 1
    fi
elif [[ -e $PREFIX ]]; then
    print_error "PREFIX exists and is not a directory: ${PREFIX}"
    exit 1
fi

print_message "PREFIX directory: ${PREFIX}"

if [[ $AUTOMATIC_YES -eq 1 ]]; then
    DO_INSTALL=1
else
    read -p "Create prefix directory? (y/n) " USER_REPLY
    case "$USER_REPLY" in
    y|Y)
        DO_INSTALL=1
        ;;
    n|N)
        DO_INSTALL=0
        ;;
    *)
        print_error 'Invalid answer: ' $USER_REPLY
        DO_INSTALL=0;
        ;;
    esac
fi

if [[ $DO_INSTALL -eq 0 ]]; then
    print_error 'Job cancel.'
    exit 1
fi

mkdir -p "$PREFIX"

if [[ ! -z $SUDO_USER && ! -z $SUDO_GID ]]; then
    chown $SUDO_USER "$PREFIX"
    chgrp $SUDO_GID "$PREFIX"
    print_message "Created $SUDO_USER's PREFIX directory: $PREFIX"
else
    print_message "Created PREFIX directory: $PREFIX"
fi

