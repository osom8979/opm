#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX

ERASE_NAMES="build external log source temp"

for i in ${ERASE_NAMES}; do
    print_message "Remove: $PREFIX/$i"
    rm -rf "$PREFIX/$i"
    check_code_or_exit
done

