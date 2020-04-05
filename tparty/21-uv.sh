#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit cmake

LIB=libuv
VER=1.30.1
EXT=.tar.gz
URL="https://codeload.github.com/libuv/libuv/tar.gz/v1.30.1"
MD5=e50543fdebf326551374a194a11ccaab
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

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

STEP=$LIB-config run_step cmake                \
    -DCMAKE_INSTALL_PREFIX=$TPARTY_PREFIX      \
    -DBUILD_SHARED_LIBS=ON                     \
    -DCMAKE_C_FLAGS=-I$TPARTY_PREFIX/include   \
    -DCMAKE_CXX_FLAGS=-I$TPARTY_PREFIX/include \
    -DCMAKE_LINK_FLAGS=-L$TPARTY_PREFIX/lib    \
    -DCMAKE_BUILD_TYPE=Release                 \
    -DBUILD_TESTING=OFF                        \
    "$BUILD_PREFIX/$SRC"

STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

