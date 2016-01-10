#!/bin/bash

## Don't remove DEPENDENCY variable.
DEPENDENCY=

if [[ -z $OPM_LOCAL ]]; then
    echo 'Not defined OPM_LOCAL variable.'
    exit 1
fi

if [[ -z $OPM_TMP ]]; then
    echo 'Not defined OPM_TMP variable.'
    exit 1
fi

NAME='libvorbis-1.3.5'
URL='http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz'
MD5='28cb28097c07a735d6af56e598e1c90f'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.xz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libvorbis.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" \
    "$TEMP_DIR" "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

