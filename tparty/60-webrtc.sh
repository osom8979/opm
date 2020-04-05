#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit BUILD_PREFIX
exists_program_or_exit git
exists_program_or_exit ninja
exists_program_or_exit python  ## python-2.7

DEPOT_TOOLS_PATH="$BUILD_PREFIX/depot_tools"
PATH=$PATH:$DEPOT_TOOLS_PATH
if [[ -d "$DEPOT_TOOLS_PATH" ]]; then
    cd "$DEPOT_TOOLS_PATH"
    git pull
else
    git clone --depth 1 "https://chromium.googlesource.com/chromium/tools/depot_tools.git" "$DEPOT_TOOLS_PATH"
fi

LIB=webrtc
VER=m79
SRC=$LIB-$VER

WEBRTC_BUILD_DIR="$BUILD_PREFIX/$SRC"
if [[ ! -d "$WEBRTC_BUILD_DIR" ]]; then
    mkdir -p "$WEBRTC_BUILD_DIR"
fi
cd "$WEBRTC_BUILD_DIR"

WEBRTC_SRC_DIR="$WEBRTC_BUILD_DIR/src"
if [[ ! -d "$WEBRTC_SRC_DIR" ]]; then
    STEP=$LIB-fetch run_step fetch --nohooks webrtc
fi
cd "$WEBRTC_SRC_DIR"

BRANCH_NAME=branch-heads/$VER
CURRENT_BRANCH=`git status | sed -n '1s/HEAD detached at \(.*\)/\1/p'`
if [[ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]]; then
    git checkout "$BRANCH_NAME"
    gclient sync
fi

FLAGS="$FLAGS target_cpu=\"x64\""
FLAGS="$FLAGS is_component_build=false"
FLAGS="$FLAGS ffmpeg_branding=\"Chrome\""
FLAGS="$FLAGS rtc_use_h264=true"
FLAGS="$FLAGS rtc_use_x11=false"
FLAGS="$FLAGS rtc_build_examples=false"
FLAGS="$FLAGS rtc_include_tests=false"
FLAGS="$FLAGS use_rtti=true"  ## Include typeinfo
FLAGS="$FLAGS use_custom_libcxx=false"

if [[ $RELEASE_FLAG -eq 0 ]]; then
    print_message "Enable Debug Mode."
    FLAGS="$FLAGS is_debug=true"
    FLAGS="$FLAGS symbol_level=2"
else
    print_message "Enable Release Mode."
    FLAGS="$FLAGS is_debug=false"
    FLAGS="$FLAGS symbol_level=2"
fi

STEP=$LIB-config run_step gn gen out/release "'--args=$FLAGS'"
STEP=$LIB-build  run_step ninja -C out/release

print_message "Install webrtc library"
WEBRTC_PREFIX=$TPARTY_PREFIX/webrtc-$VER
mkdir -p "$WEBRTC_PREFIX/lib"
mkdir -p "$WEBRTC_PREFIX/include"

find out/release -name '*.a' | xargs -I {} cp {} $WEBRTC_PREFIX/lib
find out/release -iname "*.h" | grep -v 'AppRTCMobile.app' | grep -v 'WebRTC.framework' | xargs -I {} cp {} $WEBRTC_PREFIX/include

find . -name '*.h' | sed 's;/[^/]*\.h$;;g' | sort | uniq | xargs -I {} mkdir -p $WEBRTC_PREFIX/include/{}
find . -name '*.h' | xargs -I {} cp {} $WEBRTC_PREFIX/include/{}

