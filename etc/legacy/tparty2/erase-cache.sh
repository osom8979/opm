#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX

ERASE_NAMES="build external log source temp"

for i in ${ERASE_NAMES}; do
    print_message "Remove: $TPARTY_PREFIX/$i"
    rm -rf "$TPARTY_PREFIX/$i"
    check_code_or_exit
done

