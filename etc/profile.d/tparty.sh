#!/usr/bin/env bash

if [[ -z $TPARTY_PREFIX ]]; then
    TPARTY_PREFIX=/usr/local/tparty
fi

if [[ ! -d $TPARTY_PREFIX ]]; then
    # Not found TPARTY_PREFIX directory.
    # But, not error.
    return 0
fi

export TPARTY_PREFIX

TPARTY_BIN=$TPARTY_PREFIX/bin
TPARTY_INC=$TPARTY_PREFIX/include
TPARTY_LIB=$TPARTY_PREFIX/lib
TPARTY_PKG=$TPARTY_LIB/pkgconfig

if [[ -d $TPARTY_BIN ]]; then
    export PATH="$TPARTY_BIN:$PATH"
fi
if [[ -d $TPARTY_INC ]]; then
    export CPATH="$TPARTY_INC:$CPATH"
fi
if [[ -d $TPARTY_LIB ]]; then
    export LIBRARY_PATH="$TPARTY_LIB:$LIBRARY_PATH"
    #export LD_LIBRARY_PATH
    #export DYLD_LIBRARY_PATH
    #export DYLD_FALLBACK_LIBRARY_PATH
    if [[ -d $TPARTY_PKG ]]; then
        export PKG_CONFIG_PATH="$TPARTY_PKG:$PKG_CONFIG_PATH"
    fi
fi

echo "[Tparty Environment]"
echo " CFLAGS=\"-I${TPARTY_INC}\""
echo " LDFLAGS=\"-L${TPARTY_LIB}\""

