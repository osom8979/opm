#!/bin/bash

NAME='libvorbis-1.3.5'
URL='http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz'
MD5='28cb28097c07a735d6af56e598e1c90f'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.xz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL_LIB/libvorbis.a"
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

