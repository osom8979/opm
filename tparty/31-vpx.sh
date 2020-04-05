#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
check_variable_or_exit PLATFORM
exists_program_or_exit patch
exists_program_or_exit yasm

LIB=libvpx
VER=1.8.0
EXT=.tar.gz
URL="https://codeload.github.com/webmproject/libvpx/tar.gz/v1.8.0"
MD5=49cb591325f44a3459b040112e3b82e7
FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

FLAGS="--prefix=$TPARTY_PREFIX"
FLAGS="$FLAGS --enable-pic"
FLAGS="$FLAGS --enable-shared"
FLAGS="$FLAGS --enable-static"
FLAGS="$FLAGS --enable-vp8"
FLAGS="$FLAGS --enable-vp9"
FLAGS="$FLAGS --as=yasm"
FLAGS="$FLAGS --disable-examples"
FLAGS="$FLAGS --disable-tools"
FLAGS="$FLAGS --disable-docs"
FLAGS="$FLAGS --disable-unit-tests"

if [[ "$PLATFORM" == "Darwin" ]]; then
    #FLAGS="$FLAGS --target=x86_64-darwin17-gcc"
    STEP=$LIB-patch run_step patch -p 1 < "$WORKING/31-vpx.darwin.patch"
fi

STEP=$LIB-config  run_step ./configure $FLAGS
STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

# Only static-build required.
# sed -i.tmp 's/^\(Libs:.*\)$/\1 -lpthread/g' $TPARTY_PREFIX/lib/pkgconfig/vpx.pc

