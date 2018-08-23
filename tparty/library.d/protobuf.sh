#!/bin/bash

if [[ -z $TPARTY_HOME ]]; then
    echo 'Not defined TPARTY_HOME variable.'
    exit 1
fi

TPARTY_LOCAL=$TPARTY_HOME/local
TPARTY_TMP=$TPARTY_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=zlib.sh:
build-dependency $DEPENDENCIES

#NAME='protobuf-3.0.0-beta-2'
#URL='https://codeload.github.com/google/protobuf/tar.gz/v3.0.0-beta-2'
#MD5='e7f2602baffcbc27fb607de659cfbab6'
#PATCH='protobuf-3.0.0-beta-2.fix.diff'

NAME='protobuf-3.0.0'
URL='https://codeload.github.com/google/protobuf/tar.gz/v3.0.0'
MD5='d4f6ca65aadc6310b3872ee421e79fa6'
PATCH='protobuf-3.0.0.fix.diff'

PATCH_PATH="$TPARTY_HOME/library.d/$PATCH"
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libprotobuf.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    patch -p1 < $PATCH_PATH >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    ./autogen.sh >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$TPARTY_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make $THREAD_FLAG >> $LOG_PATH

    #code=$?; [[ $code != 0 ]] && exit $code
    #make check >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

