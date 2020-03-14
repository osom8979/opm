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

#NAME='openh264-1.5.0'
#URL='https://codeload.github.com/cisco/openh264/tar.gz/v1.5.0'
#MD5='ac32a23821887cd2202700aa59c1d4be'

#NAME='openh264-1.7.0'
#URL='https://codeload.github.com/cisco/openh264/tar.gz/v1.7.0'
#MD5='93da4e76cfda7ede8fd2df51b0021efd'

NAME='openh264-1.8.0'
URL='https://codeload.github.com/cisco/openh264/tar.gz/v1.8.0'
MD5='3ab5a96ba97cfad8f50deb23a4350bba'

TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libopenh264.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install PREFIX=$TPARTY_LOCAL >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

