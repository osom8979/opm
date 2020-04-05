#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit EXTERNAL_PREFIX
check_variable_or_exit PLATFORM

case "$PLATFORM" in
Darwin)
    GEN_OS=macosx
    ;;
Linux)
    GEN_OS=linux-64bit
    ;;
*)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

LIB=live
VER=2019.05.29
EXT=.tar.gz
URL="http://www.live555.com/liveMedia/public/live.2019.05.29.tar.gz"
MD5=bcf5fb8de85c7c49cb08a938fb05915f
FILE=$LIB-$VER$EXT
SRC=live

if [[ -d "$EXTERNAL_PREFIX/live555-$VER" ]]; then
    cp -r "$EXTERNAL_PREFIX/live555-$VER" "$BUILD_PREFIX/$SRC"
else
    checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
    extract "$SOURCE_PREFIX/$FILE" "$BUILD_PREFIX"
fi
cd "$BUILD_PREFIX/$SRC"

STEP=$LIB-config  run_step ./genMakefiles $GEN_OS
STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make PREFIX="$TPARTY_PREFIX" install

