#!/bin/bash

if [[ ! -d $TPARTY_HOME ]]; then
    # Not found TPARTY_HOME variable.
    # But, not error.
    return 0
fi

TPARTY_LOCAL=$TPARTY_HOME/local
TPARTY_BIN=$TPARTY_LOCAL/bin
TPARTY_INC=$TPARTY_LOCAL/include
TPARTY_LIB=$TPARTY_LOCAL/lib

## GCC setting.
export  PATH="$TPARTY_BIN:$PATH"
export  CPATH="$TPARTY_INC:$CPATH"
export  LIBRARY_PATH="$TPARTY_LIB:$LIBRARY_PATH"
#export LD_LIBRARY_PATH="$TPARTY_LIB:$LD_LIBRARY_PATH"
#export DYLD_LIBRARY_PATH="$TPARTY_LIB:$DYLD_LIBRARY_PATH"
export  DYLD_FALLBACK_LIBRARY_PATH="$TPARTY_LIB:$DYLD_FALLBACK_LIBRARY_PATH"

## Pkg-config setting.
export PKG_CONFIG_PATH="$TPARTY_LIB/pkgconfig:$PKG_CONFIG_PATH"

echo "[Tparty Environment]"
echo " CFLAGS=\"-I${TPARTY_INC}\""
echo " LDFLAGS=\"-L${TPARTY_LIB}\""

