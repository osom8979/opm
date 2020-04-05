#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit autoconf

LIB=jemalloc
VER=5.2.1
EXT=.tar.gz
URL="https://codeload.github.com/jemalloc/jemalloc/tar.gz/5.2.1"
MD5=0d627898d4aa58d09ef5d3fdde17dacb
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

STEP=$LIB-config  run_step ./autogen.sh --prefix=$TPARTY_PREFIX
STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

