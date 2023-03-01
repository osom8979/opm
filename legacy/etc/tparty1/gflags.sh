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

NAME='gflags-2.1.2'
URL='https://codeload.github.com/gflags/gflags/tar.gz/v2.1.2'
MD5='ac432de923f9de1e9780b5254884599f'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libgflags.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    cmake -DCMAKE_INSTALL_PREFIX=$TPARTY_LOCAL \
          -DCMAKE_BUILD_TYPE=Release           \
          -DCMAKE_CXX_FLAGS=-fPIC              \
          -DCMAKE_C_FLAGS=-fPIC                \
          -G 'Unix Makefiles' >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make VERBOSE=0 >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

