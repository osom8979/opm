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

NAME='icu'
URL='http://download.icu-project.org/files/icu4c/57.1/icu4c-57_1-src.tgz'
MD5='976734806026a4ef8bdd17937c8898b9'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tgz"
WORK_NAME="$NAME/source"
ALREADY="$TPARTY_LOCAL/include/unicode/utf8.h"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    #./configure --with-data-packaging=static --prefix=$TPARTY_LOCAL >> $LOG_PATH
    ./configure --disable-shared --enable-static prefix=$TPARTY_LOCAL >> $LOG_PATH

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

