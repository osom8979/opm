#!/usr/bin/env bash

WORKING=$PWD
PLATFORM=`uname -s`

case "$PLATFORM" in
Darwin)
    MD5_CMD='md5 -r'
    CORE_COUNT=`sysctl -n hw.ncpu`
    let "THREAD_COUNT = $CORE_COUNT * 2"
    ;;
Linux)
    MD5_CMD='md5sum'
    CORE_COUNT=`grep -c ^processor /proc/cpuinfo`
    let "THREAD_COUNT = $CORE_COUNT * 2"
    ;;
*)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

YASM_CMD=`which yasm`
if [[ ! -x "$YASM_CMD" ]]; then
    echo 'Not found yasm'
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

LIB=libvpx
VER=1.8.0
EXT=.tar.gz
URL="https://codeload.github.com/webmproject/libvpx/tar.gz/v1.8.0"
MD5=49cb591325f44a3459b040112e3b82e7
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

SOURCE_DIR="$WORKING/libvpx-1.8.0"
if [[ -d "$SOURCE_DIR" ]]; then
    echo "Exists source directory: $SOURCE_DIR"
else
    echo "Extract source: $NAME"
    tar xf $NAME
fi

cd $SOURCE_DIR
DATETIME=`date +%Y%m%d_%H%M%S`
BUILD_LOG1=$WORKING/$LIB-$VER-config-$DATETIME.log
BUILD_LOG2=$WORKING/$LIB-$VER-build-$DATETIME.log
BUILD_LOG3=$WORKING/$LIB-$VER-install-$DATETIME.log

FLAGS="--prefix=$PREFIX"
FLAGS="$FLAGS --enable-pic"
FLAGS="$FLAGS --disable-shared"
FLAGS="$FLAGS --enable-static"
FLAGS="$FLAGS --enable-vp8"
FLAGS="$FLAGS --enable-vp9"
FLAGS="$FLAGS --as=yasm"
FLAGS="$FLAGS --disable-examples"
FLAGS="$FLAGS --disable-tools"
FLAGS="$FLAGS --disable-docs"
FLAGS="$FLAGS --disable-unit-tests"

if [[ "$PLATFORM" == "Darwin" ]]; then
    FLAGS="$FLAGS --target=x86_64-darwin17-gcc"
fi

./configure $FLAGS | tee $BUILD_LOG1
CODE=$?
echo "Config done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

make -j$THREAD_COUNT | tee $BUILD_LOG2
CODE=$?
echo "Build done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

make install | tee $BUILD_LOG3
echo "Install done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

sed -i.tmp 's/^\(Libs:.*\)$/\1 -lpthread/g' $PREFIX/lib/pkgconfig/vpx.pc
echo "Update vpx.pc done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

