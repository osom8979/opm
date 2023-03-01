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

NAME='googletest-release-1.7.0'
URL='https://codeload.github.com/google/googletest/tar.gz/release-1.7.0'
MD5='4ff6353b2560df0afecfbda3b2763847'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libgtest.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    autoreconf -ifv >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$TPARTY_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    # make install is dangerous and not supported.
    # make install >> $LOG_PATH

    # Custom install process:
    if [[ ! -d "$TPARTY_LOCAL/include" ]]; then mkdir -p "$TPARTY_LOCAL/include"; fi
    if [[ ! -d "$TPARTY_LOCAL/lib"     ]]; then mkdir -p "$TPARTY_LOCAL/lib";     fi
    cp -r include/gtest "$TPARTY_LOCAL/include"
    local lib_files=`find . -iname '*.a' | grep -v samples`
    for cursor in $lib_files; do
        cp $cursor "$TPARTY_LOCAL/lib/"
    done
}

function runWindows {
    code=$?; [[ $code != 0 ]] && exit $code
    cd make # IMPORTANT!!

    code=$?; [[ $code != 0 ]] && exit $code
    make gtest_main.a gtest.a >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    # Custom install process:
    if [[ ! -d "$TPARTY_LOCAL/include" ]]; then mkdir -p "$TPARTY_LOCAL/include"; fi
    if [[ ! -d "$TPARTY_LOCAL/lib"     ]]; then mkdir -p "$TPARTY_LOCAL/lib";     fi
    cp -r ../include/gtest "$TPARTY_LOCAL/include"
    cp gtest_main.a "$TPARTY_LOCAL/lib/libgtest_main.a"
    cp gtest.a "$TPARTY_LOCAL/lib/libgtest.a"
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

