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

NAME='boost_1_60_0'
URL='http://pilotfiber.dl.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.gz'
MD5='28f58b9a33469388302110562bdf6188'

NAME='boost_1_59_0'
URL='http://pilotfiber.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz'
MD5='51528a0e3b33d9e10aaa311d9eb451e3'

TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$TPARTY_LOCAL/lib/libboost_system.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

FLAGS="--prefix=$TPARTY_LOCAL"
FLAGS="$FLAGS $THREAD_FLAG"
FLAGS="$FLAGS variant=release"
FLAGS="$FLAGS link=shared"
FLAGS="$FLAGS threading=multi"
FLAGS="$FLAGS install"
# Other flags:
# --layout=system

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    ./bootstrap.sh >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    ./b2 $FLAGS >> $LOG_PATH
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

