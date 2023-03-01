#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX

LIB=st
VER=0.8.2
EXT=.tar.gz
URL="https://dl.suckless.org/st/st-0.8.2.tar.gz"
MD5=a3d97ee92215071e6399691edc0f04b0
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

STEP=$LIB-config \
    run_step cp -f "$SCRIPT_DIR/70-st.config.h" "$BUILD_PREFIX/$SRC/config.h"

STEP=$LIB-build \
    run_step make -j$(get_build_thread_count)

STEP=$LIB-install \
    run_step make install PREFIX=$TPARTY_PREFIX

