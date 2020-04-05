#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit yasm

LIB=ffmpeg

#VER=4.1.3
#EXT=.tar.bz2
#URL="https://ffmpeg.org/releases/ffmpeg-4.1.3.tar.bz2"
#MD5=9985185a8de3678e5b55b1c63276f8b5

VER=4.2.2
EXT=.tar.bz2
URL="https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2"
MD5=829d56f158832dbf669b5b417af48060

FILE=$LIB-$VER$EXT
SRC=$LIB-$VER

if [[ -d "$EXTERNAL_PREFIX/$SRC" ]]; then
    cp -r "$EXTERNAL_PREFIX/$SRC" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

FLAGS="$FLAGS --prefix=$TPARTY_PREFIX"
FLAGS="$FLAGS --extra-ldflags=-Wl,-rpath,$TPARTY_PREFIX/lib"
FLAGS="$FLAGS --enable-pic"
FLAGS="$FLAGS --disable-static"
FLAGS="$FLAGS --enable-shared"
FLAGS="$FLAGS --enable-x86asm"
FLAGS="$FLAGS --enable-libopenh264"
FLAGS="$FLAGS --enable-libvpx"
FLAGS="$FLAGS --disable-doc"

if [[ ! -z $SYMBOL_FLAG && $SYMBOL_FLAG -gt 0 ]]; then
    FLAGS="$FLAGS --enable-debug=$SYMBOL_FLAG"
    FLAGS="$FLAGS --disable-stripping"
    FLAGS="$FLAGS --extra-cflags=-g"
    if [[ $SYMBOL_FLAG -ge 3 ]]; then
        FLAGS="$FLAGS --assert-level=2"
    fi
fi

PKG_CONFIG_PATH=$TPARTY_PREFIX/lib/pkgconfig \
    STEP=$LIB-config \
    run_step ./configure $FLAGS

STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

