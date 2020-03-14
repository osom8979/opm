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

#NAME='SFML-2.4.0'
#URL='https://codeload.github.com/SFML/SFML/tar.gz/2.4.0'
#MD5='4e09580bc162ffb347d5ecda17a8d026'

NAME='SFML-2.5.0'
URL='https://codeload.github.com/SFML/SFML/tar.gz/2.5.0'
MD5='643b6bf93a90cf49d060b2d76466f089'

TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME/build"
ALREADY="$TPARTY_LOCAL/include/SFML/Config.hpp"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code

    # SFML 2.4.0
    #cmake -DCMAKE_INSTALL_PREFIX=$TPARTY_LOCAL \
    #      -DCMAKE_INSTALL_FRAMEWORK_PREFIX=$TPARTY_LOCAL/Library/Frameworks \
    #      -DBUILD_SHARED_LIBS=ON               \
    #      -DCMAKE_BUILD_TYPE=Release           \
    #      -DCMAKE_CXX_FLAGS=-fPIC              \
    #      -DCMAKE_C_FLAGS=-fPIC                \
    #      -G 'Unix Makefiles' .. >> $LOG_PATH

    # SFML 2.5.0
    cmake -DCMAKE_INSTALL_PREFIX=$TPARTY_LOCAL \
          -DSFML_DEPENDENCIES_INSTALL_PREFIX=$TPARTY_LOCAL/Library/Frameworks \
          -DBUILD_SHARED_LIBS=ON               \
          -DCMAKE_BUILD_TYPE=Release           \
          -DCMAKE_CXX_FLAGS=-fPIC              \
          -DCMAKE_C_FLAGS=-fPIC                \
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
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"

