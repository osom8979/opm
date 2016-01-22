#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

OPM_LOCAL=$OPM_HOME/local
OPM_TMP=$OPM_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

NAME='ffmpeg-2.8.5.tar.bz2'
URL='http://ffmpeg.org/releases/ffmpeg-2.8.5.tar.bz2'
MD5='989d9024313c2b7e2eeaed58b751c0ee'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.bz2"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libavcodec.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    FLAGS='--pkg-config-flags=--static'
    FLAGS="$FLAGS --extra-cflags=-fPIC"
    FLAGS="$FLAGS --enable-static"
    FLAGS="$FLAGS --enable-shared"
    FLAGS="$FLAGS --enable-gpl"
    FLAGS="$FLAGS --enable-libass"
    FLAGS="$FLAGS --enable-libfdk-aac"
    FLAGS="$FLAGS --enable-libfreetype"
    FLAGS="$FLAGS --enable-libmp3lame"
    FLAGS="$FLAGS --enable-libopus"
    FLAGS="$FLAGS --enable-libtheora"
    FLAGS="$FLAGS --enable-libvorbis"
    FLAGS="$FLAGS --enable-libvpx"
    FLAGS="$FLAGS --enable-libx264"
    FLAGS="$FLAGS --enable-libx265"
    FLAGS="$FLAGS --enable-nonfree"

    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL $FLAGS >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" \
    "$TEMP_DIR" "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

