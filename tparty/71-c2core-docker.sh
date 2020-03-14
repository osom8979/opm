#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
PROJECT_ROOT_DIR=`_cur="$PWD" ; cd "$WORKING/../.." ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX
check_variable_or_exit REMOVE_CACHE
exists_program_or_exit cmake
exists_program_or_exit make

LIB=c2core
SRC_DIR="$PROJECT_ROOT_DIR"
CMAKE_BUILD_DIR="$SRC_DIR/cmake-build-release"
if [[ ! -d "$CMAKE_BUILD_DIR" ]]; then
    mkdir -p "$CMAKE_BUILD_DIR"
fi

pushd "$PWD" > /dev/null
cd "$CMAKE_BUILD_DIR"

STEP=$LIB-config run_step cmake         \
    -DCMAKE_INSTALL_PREFIX=$PREFIX      \
    -DBUILD_SHARED_LIBS=ON              \
    -DCMAKE_BUILD_TYPE=Release          \
    -DC2CORE_DISABLE_AUTHENTICATION=ON  \
    -DC2CORE_DOCKER_AUTHENTICATION=ON   \
    "$SRC_DIR"
STEP=$LIB-build   run_step make -j$(get_build_thread_count)
STEP=$LIB-install run_step make install

popd > /dev/null

if [[ $REMOVE_CACHE -eq 1 ]]; then
    print_message "Remove: $CMAKE_BUILD_DIR"
    rm -rf "$CMAKE_BUILD_DIR"
    check_code_or_exit
fi

