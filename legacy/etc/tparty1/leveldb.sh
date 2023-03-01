#!/bin/bash

if [[ -z $TPARTY_HOME ]]; then
    echo 'Not defined TPARTY_HOME variable.'
    exit 1
fi

TPARTY_LOCAL=$TPARTY_HOME/local
TPARTY_TMP=$TPARTY_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=snappy.sh:
build-dependency $DEPENDENCIES

NAME='leveldb-1.18'
URL='https://codeload.github.com/google/leveldb/tar.gz/v1.18'
MD5='73770de34a2a5ab34498d2e05b2b7fa0'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libleveldb.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    make "OPT=-O2 -DNDEBUG" >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    if [[ ! -d "$TPARTY_LOCAL/include" ]]; then mkdir -p "$TPARTY_LOCAL/include"; fi
    if [[ ! -d "$TPARTY_LOCAL/lib"     ]]; then mkdir -p "$TPARTY_LOCAL/lib";     fi
    cp -rf include/leveldb $TPARTY_LOCAL/include/leveldb
    cp *.a   $TPARTY_LOCAL/lib/
    cp *.so  $TPARTY_LOCAL/lib/
}

function runWindows {
    echo "Unsupported platform." 1>&2
    exit 1
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

