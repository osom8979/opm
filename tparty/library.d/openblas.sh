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

NAME='OpenBLAS-0.2.15'
URL='https://codeload.github.com/xianyi/OpenBLAS/tar.gz/v0.2.15'
MD5='b1190f3d3471685f17cfd1ec1d252ac9'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libopenblas.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    patch -p1 < $TPARTY_HOME/library.d/openblas-0.2.15.fix.diff >> $LOG_PATH

    #code=$?; [[ $code != 0 ]] && exit $code
    #make FC=gfortran DYNAMIC_ARCH=1 >> $LOG_PATH

    # Don't use THREAD_FLAG.
    # Warning: -jN forced in submake: disabling jobserver mode.
    code=$?; [[ $code != 0 ]] && exit $code
    make ONLY_CBLAS=1 NO_LAPACKE=1 DYNAMIC_ARCH=1 "CFLAGS=-Wno-unused-but-set-variable -Wno-unused-variable -Wno-uninitialized" >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make PREFIX=$TPARTY_LOCAL install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

