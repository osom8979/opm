#!/bin/bash

NAME='jpeg-9a'
URL='http://www.ijg.org/files/jpegsrc.v9a.tar.gz'
MD5='3353992aecaee1805ef4109aadd433e7'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL_LIB/libjpeg.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    check-exit
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    check-exit
    make >> $LOG_PATH

    check-exit
    make install >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" \
    "$TEMP_DIR" "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

