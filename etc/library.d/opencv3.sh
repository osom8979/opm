#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

OPM_LOCAL=$OPM_HOME/local
OPM_TMP=$OPM_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

NAME='opencv-3.1.0'
URL='https://codeload.github.com/Itseez/opencv/tar.gz/3.1.0'
MD5='70e1dd07f0aa06606f1bc0e3fa15abd3'
TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libopencv_ts.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    cmake -DCMAKE_INSTALL_PREFIX=$OPM_LOCAL \
          -DBUILD_SHARED_LIBS=ON            \
          -DCMAKE_BUILD_TYPE=Release        \
          -DCMAKE_CXX_FLAGS=-fPIC           \
          -DCMAKE_C_FLAGS=-fPIC             \
          -DWITH_CUDA=OFF                   \
          -DWITH_FFMPEG=OFF                 \
          -DBUILD_opencv_python2=OFF        \
          -G 'Unix Makefiles' .. >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make $THREAD_FLAG >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"     \
    "$DEPENDENCIES"

