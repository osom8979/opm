#!/bin/bash

if [[ ! -d $TPARTY_HOME ]]; then
    # Not found TPARTY_HOME variable.
    # But, not error.
    return 0
fi

TPARTY_LOCAL=$TPARTY_HOME/local

## GCC setting.
export PATH="$TPARTY_HOME:$PATH"
export CPATH="$TPARTY_LOCAL/include:$CPATH"
export LIBRARY_PATH="$TPARTY_LOCAL/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$TPARTY_LOCAL/lib:$LD_LIBRARY_PATH"
#export DYLD_LIBRARY_PATH="$TPARTY_LOCAL/lib:$DYLD_LIBRARY_PATH"

## Pkg-config setting.
export PKG_CONFIG_PATH="$TPARTY_LOCAL/lib/pkgconfig:$PKG_CONFIG_PATH"

