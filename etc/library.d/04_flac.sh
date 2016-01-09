#!/bin/bash

NAME='flac-1.3.1'
URL='http://downloads.xiph.org/releases/flac/flac-1.3.1.tar.xz'
MD5='b9922c9a0378c88d3e901b234f852698'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.xz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL_LIB/libFLAC.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL --enable-static --enable-shared >> $LOG_PATH

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

