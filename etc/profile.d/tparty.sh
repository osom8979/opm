#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    return 0
fi

TPARTY_DIR=$OPM_HOME/tparty
if [[ -f "$TPARTY_DIR/__default__" ]]; then
    source "$TPARTY_DIR/__default__"
fi

export TPARTY_PREFIX=${PREFIX:-/usr/local/c2core}
export TPARTY_BIN=$TPARTY_PREFIX/bin
export TPARTY_INC=$TPARTY_PREFIX/include
export TPARTY_LIB=$TPARTY_PREFIX/lib
export TPARTY_PKG=$TPARTY_LIB/pkgconfig

export PATH=$TPARTY_BIN:$PATH
export CPATH=$TPARTY_INC:$CPATH
export LIBRARY_PATH=$TPARTY_LIB:$LIBRARY_PATH
#export LD_LIBRARY_PATH
#export DYLD_LIBRARY_PATH
#export DYLD_FALLBACK_LIBRARY_PATH
export PKG_CONFIG_PATH=$TPARTY_PKG:$PKG_CONFIG_PATH

echo "[Tparty Environment]"
echo " CFLAGS=\"-I${TPARTY_INC}\""
echo " LDFLAGS=\"-L${TPARTY_LIB}\""

