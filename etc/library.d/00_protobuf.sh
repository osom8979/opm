#!/bin/bash

NAME='protobuf-3.0.0-beta-2'
URL='https://codeload.github.com/google/protobuf/tar.gz/v3.0.0-beta-2'
MD5='e7f2602baffcbc27fb607de659cfbab6'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL_LIB/libprotobuf.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    check-exit
    ./autogen.sh >> $LOG_PATH

    check-exit
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    check-exit
    make >> $LOG_PATH

    check-exit
    make check >> $LOG_PATH

    check-exit
    make install >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" \
    "$TEMP_DIR" "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

