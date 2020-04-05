#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
check_variable_or_exit PLATFORM

if [[ "$PLATFORM" == "Linux" ]]; then
    exists_program_or_exit patch
    exists_program_or_exit autoconf
fi

LIB=Python
VER=3.7.3
EXT=.tgz
URL="https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz"
MD5=2ee10f25e3d1b14215d56c3882486fcf
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

if [[ "$PLATFORM" == "Linux" ]]; then
    STEP=$LIB-patch    run_step patch -p 1 < "$SCRIPT_DIR/50-python3.linux.patch"
    STEP=$LIB-autoconf run_step autoconf
fi
#if [[ "$PLATFORM" == "Darwin" ]]; then
#FLAGS="--enable-framework=$TPARTY_PREFIX/Frameworks"
#fi

PKG_CONFIG_PATH=$TPARTY_PREFIX/lib/pkgconfig \
    CFLAGS="-I/opt/X11/include -I$TPARTY_PREFIX/include -fPIC" \
    LDFLAGS="-L/opt/X11/lib -L$TPARTY_PREFIX/lib -Wl,-rpath,$TPARTY_PREFIX/lib" \
    STEP=$LIB-config \
    run_step ./configure \
             --enable-shared \
             --enable-optimizations \
             --prefix=$TPARTY_PREFIX
STEP=$LIB-build-install run_step make -j$(get_build_thread_count) install

