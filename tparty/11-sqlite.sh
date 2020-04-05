#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX

LIB=sqlite
VER=snapshot-201905091837
EXT=.tar.gz
URL="https://www.sqlite.org/snapshot/sqlite-snapshot-201905091837.tar.gz"
MD5=8e94f0fae5a22898c9627b127db967e4
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

STEP=$LIB-reconf  run_step autoreconf
STEP=$LIB-config  run_step ./configure     \
                           --enable-shared \
                           --enable-static \
                           --prefix=$TPARTY_PREFIX
STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

