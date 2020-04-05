#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX

LIB=openssl
VER=1.1.1b
EXT=.tar.gz
URL="https://www.openssl.org/source/openssl-1.1.1b.tar.gz"
MD5=4532712e7bcc9414f5bce995e4e13930
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

STEP=$LIB-config  run_step ./config --release --prefix=$TPARTY_PREFIX
STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

