#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    return 0
fi

TPARTY_DIR=$OPM_HOME/tparty
if [[ -f "$TPARTY_DIR/__default__" ]]; then
    source "$TPARTY_DIR/__default__"
fi

export TPARTY_PREFIX=${TPARTY_PREFIX:-/usr/local/tparty}
export TPARTY_BIN=$TPARTY_PREFIX/bin
export TPARTY_INC=$TPARTY_PREFIX/include
export TPARTY_LIB=$TPARTY_PREFIX/lib
export TPARTY_PKG=$TPARTY_LIB/pkgconfig

if [[ -d "$TPARTY_BIN" ]]; then
export PATH=$TPARTY_BIN:$PATH
fi

#if [[ -d "$TPARTY_INC" ]]; then
#export CPATH=$TPARTY_INC:$CPATH
#fi

#if [[ -d "$TPARTY_LIB" ]]; then
#export LIBRARY_PATH=$TPARTY_LIB:$LIBRARY_PATH
#export LD_LIBRARY_PATH
#export DYLD_LIBRARY_PATH
#export DYLD_FALLBACK_LIBRARY_PATH
#fi

#if [[ -d "$TPARTY_PKG" ]]; then
#export PKG_CONFIG_PATH=$TPARTY_PKG:$PKG_CONFIG_PATH
#fi

echo "[Tparty Environment]"
echo " CFLAGS=\"-I${TPARTY_INC}\""
echo " LDFLAGS=\"-L${TPARTY_LIB}\""
echo " PKG_CONFIG_PATH=\"-L${TPARTY_PKG}\""

