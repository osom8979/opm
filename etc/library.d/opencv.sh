#!/bin/bash

return
## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

if [[ -z $OPM_LOCAL ]]; then
    echo 'Not defined OPM_LOCAL variable.'
    exit 1
fi

if [[ -z $OPM_TMP ]]; then
    echo 'Not defined OPM_TMP variable.'
    exit 1
fi

NAME='opencv-3.1.0'
URL='https://codeload.github.com/Itseez/opencv/tar.gz/3.1.0'
MD5='70e1dd07f0aa06606f1bc0e3fa15abd3'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libopencv_ts.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

function runLinux {
    code=$?; [[ $code != 0 ]] && exit $code
    cmake -DCMAKE_INSTALL_PREFIX=$OPM_LOCAL -G 'Unix Makefiles' >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make -j8 >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runLinux
MACOSX_FUNC=runLinux
WINDOWS_FUNC=runLinux

. general-build "$NAME" "$URL" "$MD5" \
    "$TEMP_DIR" "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

