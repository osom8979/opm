#!/bin/bash

NAME='zlib-1.2.8'
URL='http://zlib.net/zlib-1.2.8.tar.gz'
MD5='44d667c142d7cda120332623eab69f40'
DEST="$OPM_TMP/$NAME.tar.gz"
BUILD_DIR="$OPM_TMP/$NAME"
ALREADY="$OPM_LOCAL_LIB/libz.a"
LOG_PATH="$OPM_TMP/$NAME-`datetime`.log"

function checkExitError {
    local code=$?
    if [[ $code != 0 ]]; then
        echo " - Error signal ($code)" 1>&2
        exit $code
    fi
}

function WINDOWS_LAMBDA {
    export BINARY_PATH=$OPM_LOCAL_BIN
    export INCLUDE_PATH=$OPM_LOCAL_INC
    export LIBRARY_PATH=$OPM_LOCAL_LIB

    make all -f win32/Makefile.gcc >> $LOG_PATH

    # To use the asm code, type:
    #   cp contrib/asm?86/match.S ./match.S
    #   make LOC=-DASMV OBJA=match.o -fwin32/Makefile.gcc

    checkExitError
    make test testdll -f win32/Makefile.gcc >> $LOG_PATH

    checkExitError
    make install -f win32/Makefile.gcc SHARED_MODE=1 >> $LOG_PATH
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

GENERAL_BUILD=$OPM_HOME/etc/library.d/general-build
. $GENERAL_BUILD "$NAME" "$URL" "$MD5" "$DEST" "$BUILD_DIR" "$ALREADY" \
    "$MACOSX_LAMBDA" "$LINUX_LAMBDA" "$WINDOWS_LAMBDA" "$LOG_PATH"

