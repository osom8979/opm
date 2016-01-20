#!/bin/bash

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

if [[ -z $OPM_LOCAL ]]; then
    echo 'Not defined OPM_LOCAL variable.'
    exit 1
fi

if [[ -z $OPM_TMP ]]; then
    echo 'Not defined OPM_TMP variable.'
    exit 1
fi

NAME='fdk-aac-0.1.4'
URL='https://codeload.github.com/mstorsjo/fdk-aac/tar.gz/v0.1.4'
MD5='5292a28369a560d37d431de625bedc34'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libfdk-aac.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    autoreconf -ifv >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    export CFLAGS='-fPIC'
    export CXXFLAGS='-fPIC'
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

