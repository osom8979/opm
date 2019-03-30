#!/bin/bash

if [[ -z $TPARTY_HOME ]]; then
    echo 'Not defined TPARTY_HOME variable.'
    exit 1
fi

TPARTY_LOCAL=$TPARTY_HOME/local
TPARTY_TMP=$TPARTY_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

NAME='live'
URL='http://www.live555.com/liveMedia/public/live.2016.01.29.tar.gz'
MD5='6275484ab763673ad3144648bf1015cb'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/bin/openRTSP"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    ./genMakefiles linux-with-shared-libraries

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make "DESTDIR=$TPARTY_LOCAL" "PREFIX=" install >> $LOG_PATH
}

function runMacOSX {
    code=$?; [[ $code != 0 ]] && exit $code
    ./genMakefiles macosx

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make "DESTDIR=$TPARTY_LOCAL" "PREFIX=" install >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    LIB_NAME=liblive555.dylib
    g++ -o $LIB_NAME -Wl,-all_load -dynamiclib \
        -LBasicUsageEnvironment -Lgroupsock -LliveMedia -LUsageEnvironment \
        -lBasicUsageEnvironment -lgroupsock -lliveMedia -lUsageEnvironment >> $LOG_PATH
    cp $LIB_NAME $TPARTY_LOCAL/lib/$LIB_NAME
}

function runWindows {
    code=$?; [[ $code != 0 ]] && exit $code
    ./genWindowsMakefiles

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make "DESTDIR=$TPARTY_LOCAL" "PREFIX=" install >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runMacOSX
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"     \
    "$DEPENDENCIES"

