#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit PLATFORM
check_variable_or_exit DATETIME

find "$TPARTY_PREFIX" -maxdepth 1 -a -type d \
    -a ! -path "$TPARTY_PREFIX"              \
    -a ! -path "$TPARTY_PREFIX/build"        \
    -a ! -path "$TPARTY_PREFIX/external"     \
    -a ! -path "$TPARTY_PREFIX/log"          \
    -a ! -path "$TPARTY_PREFIX/source"       \
    -a ! -path "$TPARTY_PREFIX/temp" |       \
    xargs tar vczf "c2core-prerequisite-$PLATFORM-$DATETIME.tar.gz"

