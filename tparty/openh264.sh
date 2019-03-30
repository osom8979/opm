#!/usr/bin/env bash

WORKING=$PWD
PLATFORM=`uname -s`

case "$PLATFORM" in
Darwin)
    MD5_CMD='md5 -r'
    ;;
Linux)
    MD5_CMD='md5sum'
    ;;
*)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

NASM_CMD=`which nasm`
if [[ ! -x "$NASM_CMD" ]]; then
    echo 'Not found nasm'
    exit 1
fi

CURL_CMD=`which curl`
if [[ ! -x "$CURL_CMD" ]]; then
    echo 'Not found curl'
    exit 1
fi

PREFIX=/usr/local/tparty
if [[ ! -d "$PREFIX" ]]; then
    echo "Not found PREFIX directory: $PREFIX"
    exit 1
fi
if [[ ! -w "$PREFIX" ]]; then
    echo "The writable permission is denied: $PREFIX"
    exit 1
fi

LIB=openh264
VER=1.8.0
EXT=.tar.gz
URL="https://codeload.github.com/cisco/openh264/tar.gz/v1.8.0"
MD5=3ab5a96ba97cfad8f50deb23a4350bba
NAME=$LIB-$VER$EXT

if [[ ! -f "$NAME" ]]; then
    echo "Download $NAME"
    "$CURL_CMD" -k -o "$NAME" "$URL"
else
    echo "Exists $NAME"
fi

CHECKSUM=`$MD5_CMD $NAME | awk '{print $1}'`
if [[ "$CHECKSUM" != "$MD5" ]]; then
    echo "Checksum error: $CHECKSUM vs $MD5"
    exit 1
fi

SOURCE_DIR="$WORKING/openh264-1.8.0"
if [[ -d "$SOURCE_DIR" ]]; then
    echo "Exists source directory: $SOURCE_DIR"
else
    echo "Extract source: $NAME"
    tar xf $NAME
fi

cd $SOURCE_DIR
DATETIME=`date +%Y%m%d_%H%M%S`
BUILD_LOG=$WORKING/$LIB-$VER-$DATETIME.log

make BUILDTYPE=Release PREFIX="$PREFIX" install-static | tee $BUILD_LOG
CODE=$?
echo "Install done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

