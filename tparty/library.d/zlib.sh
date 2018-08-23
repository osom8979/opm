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

NAME='zlib-1.2.8'
URL='http://zlib.net/zlib-1.2.8.tar.gz'
MD5='44d667c142d7cda120332623eab69f40'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libz.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$TPARTY_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

function runWindows {
    export BINARY_PATH="$TPARTY_LOCAL/bin"
    export INCLUDE_PATH="$TPARTY_LOCAL/include"
    export LIBRARY_PATH="$TPARTY_LOCAL/lib"

    code=$?; [[ $code != 0 ]] && exit $code
    make all -f win32/Makefile.gcc >> $LOG_PATH

    # To use the asm code, type:
    #   cp contrib/asm?86/match.S ./match.S
    #   make LOC=-DASMV OBJA=match.o -fwin32/Makefile.gcc

    code=$?; [[ $code != 0 ]] && exit $code
    make test testdll -f win32/Makefile.gcc >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install -f win32/Makefile.gcc SHARED_MODE=1 >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runWindows

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

