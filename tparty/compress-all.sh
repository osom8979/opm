#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX
check_variable_or_exit PLATFORM
check_variable_or_exit DATETIME

find "$PREFIX" -maxdepth 1 -a -type d \
    -a ! -path "$PREFIX"              \
    -a ! -path "$PREFIX/build"        \
    -a ! -path "$PREFIX/external"     \
    -a ! -path "$PREFIX/log"          \
    -a ! -path "$PREFIX/source"       \
    -a ! -path "$PREFIX/temp" |       \
    xargs tar vczf "c2core-prerequisite-$PLATFORM-$DATETIME.tar.gz"

