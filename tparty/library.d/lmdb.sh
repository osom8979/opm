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

NAME='lmdb-LMDB_0.9.17'
URL='https://codeload.github.com/LMDB/lmdb/tar.gz/LMDB_0.9.17'
MD5='8a5501c8b8535ddd6de67e95a8633aff'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME/libraries/liblmdb"
ALREADY="$TPARTY_LOCAL/lib/liblmdb.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    make OPT=-O2 >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make "DESTDIR=" "prefix=$TPARTY_LOCAL" install >> $LOG_PATH
}

function runWindows {
    code=$?; [[ $code != 0 ]] && exit $code
    make OPT=-O2 CPPFLAGS=-D_WIN32_WINNT=0x0501 >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make "DESTDIR=" "prefix=$TPARTY_LOCAL" install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

