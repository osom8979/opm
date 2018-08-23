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

#NAME='opencv-3.1.0'
#URL='https://codeload.github.com/Itseez/opencv/tar.gz/3.1.0'
#MD5='70e1dd07f0aa06606f1bc0e3fa15abd3'

#NAME='opencv-3.2.0'
#URL='https://codeload.github.com/opencv/opencv/tar.gz/3.2.0'
#MD5='a43b65488124ba33dde195fea9041b70'

NAME='opencv-3.3.0'
URL='https://codeload.github.com/opencv/opencv/tar.gz/3.3.0'
MD5='98a4e4c6f23ec725e808a891dc11eec4'

#NAME='opencv-3.4.2'
#URL='https://codeload.github.com/opencv/opencv/tar.gz/3.4.2'
#MD5='8aba51c788cac3583bb39a0c24a5888f'

TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME/build"
ALREADY="$TPARTY_LOCAL/include/opencv/cv.h"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    # Remove options:
    # -DWITH_CUDA=OFF -DWITH_FFMPEG=OFF -DBUILD_opencv_python2=OFF
    code=$?; [[ $code != 0 ]] && exit $code
    cmake -DCMAKE_INSTALL_PREFIX=$TPARTY_LOCAL \
          -DBUILD_SHARED_LIBS=ON               \
          -DCMAKE_BUILD_TYPE=Release           \
          -DWITH_LAPACK=OFF                    \
          -DWITH_CUDA=OFF                      \
          -G 'Unix Makefiles' .. >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make $THREAD_FLAG install >> $LOG_PATH

    #code=$?; [[ $code != 0 ]] && exit $code
    #make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runCommon
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

