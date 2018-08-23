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

NAME='hdf5-1.8.17'

# HDF5 1.8.16
#URL='https://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.16.tar.gz'
#MD5='b8ed9a36ae142317f88b0c7ef4b9c618'

# HDF5 1.8.17
URL='http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.17.tar.gz'
MD5='7d572f8f3b798a628b8245af0391a0ca'

TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/include/hdf5.h"
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

function runWindows {
    mkdir cmake_build_windows
    cd cmake_build_windows

    code=$?; [[ $code != 0 ]] && exit $code
    cmake -DCMAKE_INSTALL_PREFIX=$TPARTY_LOCAL \
          -DCMAKE_BUILD_TYPE=Release           \
          -G 'Unix Makefiles' .. >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make VERBOSE=0 >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

