#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit cmake

LIB=opencv
VER=4.1.0
EXT=.tar.gz
URL="https://codeload.github.com/opencv/opencv/tar.gz/4.1.0"
MD5=b80c59c7e4feee6a00608315e02b0b73
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

PKG_CONFIG_PATH=$TPARTY_PREFIX/lib/pkgconfig            \
    STEP=$LIB-config run_step cmake                     \
        -DCMAKE_INSTALL_PREFIX=$TPARTY_PREFIX           \
        -DBUILD_SHARED_LIBS=ON                          \
        -DCMAKE_C_FLAGS=-I$TPARTY_PREFIX/include        \
        -DCMAKE_CXX_FLAGS=-I$TPARTY_PREFIX/include      \
        -DCMAKE_LINK_FLAGS=-L$TPARTY_PREFIX/lib         \
        -DCMAKE_BUILD_TYPE=Release                      \
        -DPYTHON2INTERP_FOUND=TRUE                      \
        -DPYTHON3_EXECUTABLE=$TPARTY_PREFIX/bin/python3 \
        "$BUILD_PREFIX/$SRC"

STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

