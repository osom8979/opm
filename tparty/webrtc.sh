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
    # Skip.
    ;;
Linux)
    # Skip.
    ;;
*)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

GIT_CMD=`which git`
if [[ ! -x "$GIT_CMD" ]]; then
    echo 'Not found git'
    exit 1
fi

NINJA_CMD=`which ninja`
if [[ ! -x "$NINJA_CMD" ]]; then
    echo 'Not found ninja'
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

DEPOT_TOOLS_PATH=$WORKING/depot_tools
PATH=$PATH:$DEPOT_TOOLS_PATH
if [[ ! -d "$DEPOT_TOOLS_PATH" ]]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "$DEPOT_TOOLS_PATH"
fi

LIB=webrtc
VER=72
DATETIME=`date +%Y%m%d_%H%M%S`
BUILD_LOG1=$WORKING/$LIB-$VER-fetch-$DATETIME.log
BUILD_LOG2=$WORKING/$LIB-$VER-sync-$DATETIME.log
BUILD_LOG3=$WORKING/$LIB-$VER-config-$DATETIME.log
BUILD_LOG4=$WORKING/$LIB-$VER-build-$DATETIME.log

SOURCE_DIR=$WORKING/$LIB-$VER
mkdir -p "$SOURCE_DIR"
cd "$SOURCE_DIR"

fetch --nohooks webrtc | tee $BUILD_LOG1
CODE=$?
echo "Fetch done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

cd src
BRANCH_NAME=branch-heads/$VER
git checkout $BRANCH_NAME

gclient sync | tee $BUILD_LOG2
CODE=$?
echo "Sync done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

gn gen out/release --args='ffmpeg_branding="Chrome" rtc_use_h264=true is_debug=false' | tee $BUILD_LOG3
CODE=$?
echo "Config done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

ninja -C out/release | tee $BUILD_LOG4
CODE=$?
echo "Build done: $CODE"
if [[ $CODE -ne 0 ]]; then
    exit $CODE
fi

echo "Install webrtc library"
WEBRTC_PREFIX=$PREFIX/webrtc

mkdir -p "$WEBRTC_PREFIX/lib"
mkdir -p "$WEBRTC_PREFIX/include"

find out/release -name '*.a' | xargs -I {} cp {} $WEBRTC_PREFIX/lib
find out/release -iname "*.h" | grep -v 'AppRTCMobile.app' | grep -v 'WebRTC.framework' | xargs -I {} cp {} $WEBRTC_PREFIX/include

find . -name '*.h' | sed 's;/[^/]*\.h$;;g' | sort | uniq | xargs -I {} mkdir -p $WEBRTC_PREFIX/include/{}
find . -name '*.h' | xargs -I {} cp {} $WEBRTC_PREFIX/include/{}

echo 'Done.'

