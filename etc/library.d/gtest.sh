#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

OPM_LOCAL=$OPM_HOME/local
OPM_TMP=$OPM_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

NAME='googletest-release-1.7.0'
URL='https://codeload.github.com/google/googletest/tar.gz/release-1.7.0'
MD5='4ff6353b2560df0afecfbda3b2763847'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libgtest.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    autoreconf -ifv >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    # make install is dangerous and not supported.
    # make install >> $LOG_PATH

    cp -r include/gtest "$OPM_LOCAL/include"
    local lib_files=`find . -iname '*.a' | grep -v samples`
    for cursor in $lib_files; do
        cp $cursor "$OPM_LOCAL/lib"
    done
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" \
    "$TEMP_DIR" "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

