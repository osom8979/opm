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

NAME='lua-5.3.2'
URL='http://www.lua.org/ftp/lua-5.3.2.tar.gz'
MD5='33278c2ab5ee3c1a875be8d55c1ca2a1'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/liblua.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runInstall {
    code=$?; [[ $code != 0 ]] && exit $code
    make "INSTALL_TOP=$TPARTY_LOCAL" install >> $LOG_PATH
}

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    make linux >> $LOG_PATH

    runInstall
}

function runMacOSX {
    code=$?; [[ $code != 0 ]] && exit $code
    make macosx >> $LOG_PATH

    runInstall
}

function runWindows {
    code=$?; [[ $code != 0 ]] && exit $code
    make mingw >> $LOG_PATH

    runInstall
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runMacOSX
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

