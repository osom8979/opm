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

NAME='zlib-1.2.8'
URL='http://zlib.net/zlib-1.2.8.tar.gz'
MD5='44d667c142d7cda120332623eab69f40'
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

if [[ -f $OPM_LOCAL_LIB/libz.a ]]; then
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
if [[ "$PLATFORM" == "Windows" ]]; then
    export BINARY_PATH=$OPM_LOCAL_BIN
    export INCLUDE_PATH=$OPM_LOCAL_INC
    export LIBRARY_PATH=$OPM_LOCAL_LIB

    $MAKE_CMD all -f win32/Makefile.gcc >> $LOG_PATH

    # To use the asm code, type:
    #   cp contrib/asm?86/match.S ./match.S
    #   make LOC=-DASMV OBJA=match.o -fwin32/Makefile.gcc

    checkExitError
    $MAKE_CMD test testdll -f win32/Makefile.gcc >> $LOG_PATH

    checkExitError
    $MAKE_CMD install -f win32/Makefile.gcc SHARED_MODE=1 >> $LOG_PATH
else
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    checkExitError
    $MAKE_CMD >> $LOG_PATH

    checkExitError
    $MAKE_CMD install >> $LOG_PATH
fi

cd "$WORKING"
echo "Done."

