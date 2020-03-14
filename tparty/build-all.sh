#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX
check_variable_or_exit DISTRIBUTION
check_variable_or_exit DISTRIBUTION_VERSION
check_variable_or_exit REMOVE_CACHE

if [[ ! -d "$PREFIX" ]]; then
    mkdir -p "$PREFIX"
    check_code_or_exit
fi

SRCS="$SRCS 00-dependencies-debian.sh"
SRCS="$SRCS 01-external.sh"
SRCS="$SRCS 02-clang.sh"
SRCS="$SRCS 03-cmake.sh"
SRCS="$SRCS 04-jemalloc.sh"
SRCS="$SRCS 10-zlib.sh"
SRCS="$SRCS 11-sqlite.sh"
SRCS="$SRCS 20-openssl.sh"
SRCS="$SRCS 21-uv.sh"
SRCS="$SRCS 22-event.sh"
SRCS="$SRCS 30-openh264.sh"
SRCS="$SRCS 31-vpx.sh"
SRCS="$SRCS 32-live555.sh"
SRCS="$SRCS 33-coturn.sh"
SRCS="$SRCS 40-ffmpeg.sh"
SRCS="$SRCS 41-opencv.sh"
SRCS="$SRCS 50-python3.sh"
SRCS="$SRCS 51-pip3-requirements.sh"
SRCS="$SRCS 52-pip3-pytorch.sh"
SRCS="$SRCS 60-webrtc.sh"

for i in $SRCS; do
    print_message "Run script: $i"
    bash "$WORKING/$i"

    print_message "Done(exit=$?) script: $i"
    check_code_or_exit
done

if [[ $REMOVE_CACHE -eq 1 ]]; then
    bash "$WORKING/erase-cache.sh"
fi

