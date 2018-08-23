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

NAME='spdlog-master'
URL='https://codeload.github.com/gabime/spdlog/zip/master'
MD5=
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.zip"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/include/spdlog/spdlog.h"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code

    # Custom install process:
    if [[ ! -d "$TPARTY_LOCAL/include" ]]; then
        mkdir -p "$TPARTY_LOCAL/include";
    fi
    cp -r include/spdlog "$TPARTY_LOCAL/include"
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

