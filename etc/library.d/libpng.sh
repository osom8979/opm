#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

OPM_LOCAL=$OPM_HOME/local
OPM_TMP=$OPM_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=zlib

NAME='libpng-1.6.20'
URL='http://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.20/libpng-1.6.20.tar.gz'
MD5='53166795d924950988a5513d3e605333'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libpng16.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

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

