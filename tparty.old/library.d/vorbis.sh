#!/bin/bash

if [[ -z $TPARTY_HOME ]]; then
    echo 'Not defined TPARTY_HOME variable.'
    exit 1
fi

TPARTY_LOCAL=$TPARTY_HOME/local
TPARTY_TMP=$TPARTY_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=
build-dependency $DEPENDENCIES

NAME='libvorbis-1.3.5'
URL='http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz'
MD5='28cb28097c07a735d6af56e598e1c90f'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.xz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libvorbis.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$TPARTY_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

