#!/usr/bin/env bash

ENABLE_PREFIX_CHECK=0
WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit DISTRIBUTION
check_variable_or_exit REMOVE_CACHE

if [[ "$DISTRIBUTION" == "ubuntu" ]]; then
    # common utilities.
    DEPS="git cmake curl zip bzip2 unzip"
    # build tools.
    DEPS="$DEPS autoconf automake libtool pkg-config build-essential ninja-build"
    # assembly.
    DEPS="$DEPS nasm yasm"
    # python script.
    DEPS="$DEPS python libffi-dev"
    # tbag
    DEPS="$DEPS xorg-dev libglu1-mesa-dev"

    apt-get -qq update
    apt-get -qq upgrade -y

    for i in $DEPS; do
        print_message "Test $i package."
        if [[ $(test_installed_dpkg "$i") -eq 0 ]]; then
            print_message "Install package $i"
            apt-get install -y $i
            check_code_or_exit
        fi
    done

    if [[ $REMOVE_CACHE -eq 1 ]]; then
        print_message "Clear local repository"
        apt-get clean
        apt-get autoclean
    fi
fi

