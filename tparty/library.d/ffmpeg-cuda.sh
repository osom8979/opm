#!/bin/bash

if [[ -z $TPARTY_HOME ]]; then
    echo 'Not defined TPARTY_HOME variable.'
    exit 1
fi

TPARTY_LOCAL=$TPARTY_HOME/local
TPARTY_TMP=$TPARTY_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=openh264.sh:
build-dependency $DEPENDENCIES

NAME='ffmpeg-3.3.3'
URL='http://ffmpeg.org/releases/ffmpeg-3.3.3.tar.bz2'
MD5='b3f4a71445171b2a2bb71fb6df5ced0f'

TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.bz2"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libavcodec.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

FLAGS="--prefix=$TPARTY_LOCAL"
FLAGS="$FLAGS --enable-static"
FLAGS="$FLAGS --enable-shared"
FLAGS="$FLAGS --enable-yasm"
FLAGS="$FLAGS --enable-libopenh264" # BSD style.
FLAGS="$FLAGS --enable-cuda"
FLAGS="$FLAGS --enable-cuvid"
FLAGS="$FLAGS --enable-nvenc"
FLAGS="$FLAGS --enable-nonfree"
FLAGS="$FLAGS --enable-libnpp"
FLAGS="$FLAGS --enable-pic"
FLAGS="$FLAGS --extra-cflags=-I/usr/local/cuda/include"
FLAGS="$FLAGS --extra-ldflags=-L/usr/local/cuda/lib64"

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    PKG_CONFIG_PATH=$TPARTY_LOCAL/lib/pkgconfig ./configure $FLAGS >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make $THREAD_FLAG >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

