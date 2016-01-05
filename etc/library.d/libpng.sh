#!/bin/bash

if [[ $OPM_SETUP_COMPLETE != 1 ]]; then
    echo 'Not complete opm setup.'
    exit 1
fi

if [[ -z $OPM_TMP ]]; then
    echo 'Not defined OPM_TMP variable.'
    exit 1
fi

function checkExitError {
    local ERROR_CODE=$?
    if [[ "$ERROR_CODE" != "0" ]]; then
        echo "Error signal ($ERROR_CODE)"
        exit $ERROR_CODE
    fi
}

NAME='libpng-1.6.20'
URL='http://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.20/libpng-1.6.20.tar.gz'
MD5='53166795d924950988a5513d3e605333'
DEST="$OPM_TMP/$NAME.tar.gz"

WORKING=$PWD
PLATFORM=`platform`
DATETIME=`datetime`
BUILD_NAME=$NAME-$DATETIME
BUILD_DIR=$OPM_TMP/$NAME
LOG_PATH=$OPM_TMP/$BUILD_NAME.log

MAKE_CMD=make
CURL_CMD=curl
CURL_FLAGS="-k -o"

if [[ -f $OPM_LOCAL_LIB/libpng16.a ]]; then
    echo 'Already installed.'
    return 0
fi

echo 'Download.'
if [[ -f "$DEST" ]]; then
    echo "Skip download $NAME"
else
    echo "Download $NAME"
    $CURL_CMD $CURL_FLAGS "$DEST" "$URL"

    DOWNLOAD_RESULT=$?
    if [[ $DOWNLOAD_RESULT != 0 ]]; then
        echo 'Download error.'
        exit 1
    fi
fi

echo 'Checksum.'
CHECKSUM_RESULT=`checksum "$DEST" "$MD5"`

if [[ $CHECKSUM_RESULT != 'True' ]]; then
    echo 'Checksum error.'
    exit 1
fi

echo 'Extract.'
if [[ -d "$BUILD_DIR" ]]; then
    rm -rf "$BUILD_DIR"
fi

cd "$OPM_TMP"
extract "$DEST"
checkExitError

echo 'Build.'
cd "$BUILD_DIR"

./configure --prefix=$OPM_LOCAL >> $LOG_PATH

checkExitError
$MAKE_CMD >> $LOG_PATH

checkExitError
$MAKE_CMD install >> $LOG_PATH

cd "$WORKING"
echo "Done."

