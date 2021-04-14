#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    return 1
fi

SOURCE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)
BINARY_DIR=$SOURCE_DIR/cmake-build-release
CMAKE_PATH=$(which cmake 2> /dev/null)
STRIP_PATH=$(which strip 2> /dev/null)

if [[ -z $CMAKE_PATH ]]; then
    echo "Not found cmake executable."
    return 1
fi
if [[ -z $STRIP_PATH ]]; then
    echo "Not found strip executable."
    return 1
fi

if [[ ! -d "$BINARY_DIR" ]]; then
    echo "Create build directory: $BINARY_DIR"
    mkdir -p "$BINARY_DIR"
fi

"$CMAKE_PATH" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$OPM_HOME" \
    -S "$SOURCE_DIR" \
    -B "$BINARY_DIR"

"$CMAKE_PATH" \
    --build "$BINARY_DIR" \
    --target opwm \
    -- \
    VERBOSE=1

"$CMAKE_PATH" \
    --build "$BINARY_DIR" \
    --target opwmname \
    -- \
    VERBOSE=1

"$CMAKE_PATH" \
    -P "$BINARY_DIR/cmake_install.cmake"

