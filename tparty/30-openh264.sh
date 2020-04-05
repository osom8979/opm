#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit nasm

LIB=openh264
VER=1.8.0
EXT=.tar.gz
URL="https://codeload.github.com/cisco/openh264/tar.gz/v1.8.0"
MD5=3ab5a96ba97cfad8f50deb23a4350bba
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

run_step make BUILDTYPE=Release PREFIX="$TPARTY_PREFIX" install

