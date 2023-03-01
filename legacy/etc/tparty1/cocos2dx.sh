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

NAME='cocos2d-x-3.10'
URL='http://cdn.cocos2d-x.org/cocos2d-x-3.10.zip'
MD5='c561dcc0be0ed0ed0f6ffcc80efd7d20'
TEMP_DIR="$TPARTY_TMP/build"
DEST_NAME="$NAME.zip"
WORK_NAME=
ALREADY="$TPARTY_LOCAL/$NAME/CMakeLists.txt"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"

# Don't use general-build script.
#. general-build ...

## ALREADY:
if [[ -f "$ALREADY" ]]; then
    echo " - Already installed ($ALREADY)."
    return 0
fi

## DOWNLOAD:
DEST="$TEMP_DIR/$DEST_NAME"
if [[ -f "$DEST" ]]; then
    echo " - Skip download $NAME"
else
    echo " - Download $NAME"
    curl -k -o "$DEST" "$URL"

    DOWNLOAD_RESULT=$?
    if [[ $DOWNLOAD_RESULT != 0 ]]; then
        echo ' - Download error.'
        exit 1
    fi
fi

## CHECKSUM:
CHECKSUM_RESULT=`checksum "$DEST" "$MD5"`
echo " - Checksum result: $CHECKSUM_RESULT"

if [[ $CHECKSUM_RESULT != 'True' ]]; then
    echo ' - Checksum error.'
    echo " - Remove: $DEST"
    rm -f "$DEST"
    exit 1
fi

## EXTRACT (INSTALL):
INSTALL_DIR=$TPARTY_LOCAL/$NAME
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
fi

echo " - Extract $DEST"
mkdir -p "$INSTALL_DIR"
extract "$DEST" "$INSTALL_DIR"

#echo " - Download dependencies."
#cd "$INSTALL_DIR"
#python download-deps.py >> $LOG_PATH

echo " - Example (README.md):"
echo " * cd cocos2d-x"
echo " * ./setup.py"
echo " * source FILE_TO_SAVE_SYSTEM_VARIABLE"
echo " * cocos new MyGame -p com.your_company.mygame -l cpp -d NEW_PROJECTS_DIR"
echo " * cd NEW_PROJECTS_DIR/MyGame"

