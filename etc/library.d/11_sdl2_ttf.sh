#!/bin/bash

NAME='SDL2_ttf-2.0.13'
URL='https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.13.tar.gz'
MD5='f57b13b2e51f1f8772cc1a79cdcdb14e'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL_LIB/libSDL2_ttf.a"
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

