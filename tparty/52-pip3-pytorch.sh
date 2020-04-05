#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit TPARTY_PREFIX
check_variable_or_exit PLATFORM

PIP_CMD="$TPARTY_PREFIX/bin/pip3"
if [[ ! -x "$PIP_CMD" ]]; then
    print_error "Not found $PIP_CMD"
    exit 1
fi

PYTHON_CMD="$TPARTY_PREFIX/bin/python3"
if [[ ! -x "$PYTHON_CMD" ]]; then
    print_error "Not found $PYTHON_CMD"
    exit 1
fi

PYTHON_VERSION=`"$PYTHON_CMD" --version 2>&1 | sed 's/Python \(.*\)/\1/g'`
PYTHON_MAJMIN_VERSION=`echo $PYTHON_VERSION | sed -E 's/^([0-9]+)\.([0-9]+)\..*/\1\2/g'`

if [[ -z $PYTHON_MAJMIN_VERSION ]]; then
    print_error "Unknown python version"
    exit 1
else
    print_message "Python version: $PYTHON_MAJMIN_VERSION"
fi

NVCC_WHICH_CMD=`which nvcc`
NVCC_DEFAULT_CMD='/usr/local/cuda/bin/nvcc'
if [[ -f "$NVCC_WHICH_CMD" ]]; then
    NVCC_CMD="$NVCC_WHICH_CMD"
elif [[ -f "$NVCC_DEFAULT_CMD" ]]; then
    NVCC_CMD="$NVCC_DEFAULT_CMD"
fi

if [[ -z $NVCC_CMD ]]; then
    NVCC_VERSION=
    NVCC_MAJMIN_VERSION=
    print_message "Not found nvcc executable."
else
    NVCC_VERSION=`"$NVCC_CMD" --version | grep 'release' | sed 's/.*V\([0-9.]*\)$/\1/g'`
    NVCC_MAJMIN_VERSION=`echo $NVCC_VERSION | sed -E 's/^([0-9]+)\.([0-9])+\..*/\1\2/g'`
    print_message "CUDA version: $NVCC_MAJMIN_VERSION"
fi

TORCH_PACKAGE=torch
#TORCHVISION_PACKAGE=torchvision==0.2.1  ## legacy maskrcnn-benchmark dependency
TORCHVISION_PACKAGE=torchvision

# Download the whl file with the desired version from the following html pages:
# https://download.pytorch.org/whl/cpu/torch_stable.html # CPU-only build
# https://download.pytorch.org/whl/cu80/torch_stable.html # CUDA 8.0 build
# https://download.pytorch.org/whl/cu90/torch_stable.html # CUDA 9.0 build
# https://download.pytorch.org/whl/cu92/torch_stable.html # CUDA 9.2 build
# https://download.pytorch.org/whl/cu100/torch_stable.html # CUDA 10.0 build
# https://download.pytorch.org/whl/cu101/torch_stable.html # CUDA 10.1 build

if [[ $PLATFORM == Linux ]]; then
    if [[ -z $NVCC_MAJMIN_VERSION ]]; then
        if [[ "$PYTHON_MAJMIN_VERSION" == "37" ]]; then
            TORCH_PACKAGE="https://download.pytorch.org/whl/cpu/torch-1.4.0%2Bcpu-cp37-cp37m-linux_x86_64.whl"
            TORCHVISION_PACKAGE="https://download.pytorch.org/whl/cpu/torchvision-0.5.0%2Bcpu-cp37-cp37m-linux_x86_64.whl"
        fi
    elif [[ "$NVCC_MAJMIN_VERSION" == "101" ]]; then
        if [[ "$PYTHON_MAJMIN_VERSION" == "37" ]]; then
            TORCH_PACKAGE="https://download.pytorch.org/whl/cu101/torch-1.4.0-cp37-cp37m-linux_x86_64.whl"
            TORCHVISION_PACKAGE="https://download.pytorch.org/whl/cu101/torchvision-0.5.0-cp37-cp37m-linux_x86_64.whl"
        fi
    elif [[ "$NVCC_MAJMIN_VERSION" == "100" ]]; then
        if [[ "$PYTHON_MAJMIN_VERSION" == "37" ]]; then
            TORCH_PACKAGE="https://download.pytorch.org/whl/cu100/torch-1.4.0%2Bcu100-cp37-cp37m-linux_x86_64.whl"
            TORCHVISION_PACKAGE="https://download.pytorch.org/whl/cu100/torchvision-0.5.0%2Bcu100-cp37-cp37m-linux_x86_64.whl"
        fi
    fi
fi

"$PIP_CMD" install --no-cache-dir $TORCH_PACKAGE
"$PIP_CMD" install --no-cache-dir $TORCHVISION_PACKAGE

