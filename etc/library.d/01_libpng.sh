#!/bin/bash

NAME='libpng-1.6.20'
URL='http://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.20/libpng-1.6.20.tar.gz'
MD5='53166795d924950988a5513d3e605333'
DEST="$OPM_TMP/$NAME.tar.gz"
BUILD_DIR="$OPM_TMP/$NAME"
ALREADY="$OPM_LOCAL_LIB/libpng16.a"
LOG_PATH="$OPM_TMP/$NAME-`datetime`.log"

function checkExitError {
    local code=$?
    if [[ $code != 0 ]]; then
        echo " - Error signal ($code)" 1>&2
        exit $code
    fi
}

function COMMON_LAMBDA {
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    checkExitError
    make >> $LOG_PATH

    checkExitError
    make install >> $LOG_PATH
}

MACOSX_LAMBDA=COMMON_LAMBDA
LINUX_LAMBDA=COMMON_LAMBDA
WINDOWS_LAMBDA=COMMON_LAMBDA

GENERAL_BUILD=$OPM_HOME/etc/library.d/general-build
. $GENERAL_BUILD "$NAME" "$URL" "$MD5" "$DEST" "$BUILD_DIR" "$ALREADY" \
    "$MACOSX_LAMBDA" "$LINUX_LAMBDA" "$WINDOWS_LAMBDA" "$LOG_PATH"

