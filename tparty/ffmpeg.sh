#!/usr/bin/env bash

WORKING=$PWD/build
PLATFORM=`uname -s`

if [[ ! -d $WORKING ]]; then
    mkdir -p $WORKING
fi
if [[ ! -d "$WORKING" ]]; then
    echo "Not found WORKING directory: $WORKING"
    exit 1
fi
if [[ ! -w "$WORKING" ]]; then
    echo "The writable permission is denied: $WORKING"
    exit 1
fi
cd "$WORKING"

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

if [[ -z $TPARTY_PREFIX ]]; then
PREFIX=/usr/local/tparty
else
PREFIX=$TPARTY_PREFIX
fi

if [[ ! -d "$PREFIX" ]]; then
    echo "Not found PREFIX directory: $PREFIX"
    exit 1
fi
if [[ ! -w "$PREFIX" ]]; then
    echo "The writable permission is denied: $PREFIX"
    exit 1
fi

read -p "Enable debug symbol? (y/n) " USER_REPLY
case "$USER_REPLY" in
y|Y)
    ENABLE_DEBUG=1
    ;;
*)
    ENABLE_DEBUG=0;
    ;;
esac

LIB=ffmpeg
VER=4.1.1
EXT=.tar.bz2
URL="https://www.ffmpeg.org/releases/ffmpeg-4.1.1.tar.bz2"
MD5=4a64e3cb3915a3bf71b8b60795904800
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

SOURCE_DIR="$WORKING/ffmpeg-4.1.1"
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
FLAGS="$FLAGS --extra-ldflags=-Wl,-rpath,$PREFIX/lib"
FLAGS="$FLAGS --enable-pic"
FLAGS="$FLAGS --disable-static"
FLAGS="$FLAGS --enable-shared"
FLAGS="$FLAGS --enable-x86asm"
FLAGS="$FLAGS --enable-libopenh264"
FLAGS="$FLAGS --enable-libvpx"
FLAGS="$FLAGS --disable-doc"
#FLAGS="$FLAGS --disable-programs"
if [[ $ENABLE_DEBUG -eq 1 ]]; then
FLAGS="$FLAGS --enable-debug=3"
fi

PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig ./configure $FLAGS | tee $BUILD_LOG1
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

