#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit cmake

LIB=libevent
VER=2.1.11
EXT=.tar.gz
URL="https://codeload.github.com/libevent/libevent/tar.gz/release-2.1.11-stable"
MD5=a0863610b52b7bc39fe28d0e285bab54
FILE=$LIB-$VER$EXT
SRC=$LIB-release-$VER-stable

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi

CMAKE_BUILD_DIR="$BUILD_PREFIX/$SRC/cmake-build-release"
if [[ ! -d "$CMAKE_BUILD_DIR" ]]; then
    mkdir -p "$CMAKE_BUILD_DIR"
fi
cd "$CMAKE_BUILD_DIR"

STEP=$LIB-config run_step cmake              \
    -DCMAKE_INSTALL_PREFIX=$TPARTY_PREFIX    \
    -DBUILD_SHARED_LIBS=ON                   \
    -DCMAKE_C_FLAGS=-I$TPARTY_PREFIX/include \
    -DOPENSSL_ROOT_DIR=$TPARTY_PREFIX        \
    -DZLIB_ROOT=$TPARTY_PREFIX               \
    -DCMAKE_BUILD_TYPE=Release               \
    "$BUILD_PREFIX/$SRC"

STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

