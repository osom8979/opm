#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

OPM_LOCAL=$OPM_HOME/local
OPM_TMP=$OPM_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

NAME='boost_1_60_0'
#URL='http://jaist.dl.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.gz'
URL='http://pilotfiber.dl.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.gz'
MD5='28f58b9a33469388302110562bdf6188'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libboost_system.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

FLAGS="--prefix=$OPM_LOCAL"
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

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"     \
    "$DEPENDENCIES"

