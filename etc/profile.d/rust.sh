#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

USER_NAME=$(id -u -n)

OPR_VERSION=${OPR_VERSION:-$(opm-variable OPR_VERSION)}
OPR_ENVIRON=${OPR_ENVIRON:-$(opm-variable OPR_ENVIRON)}

CARGO_DIR_NAME="opr-${USER_NAME}-${OPR_VERSION}-${OPR_ENVIRON}"

RUSTUP_DIR="$OPM_HOME/var/rust/rustup"
CARGO_DIR="$OPM_HOME/var/rust/cargo/${CARGO_DIR_NAME}"

if [[ -d "$CARGO_DIR" ]]; then
    export RUSTUP_HOME="$RUSTUP_DIR"
    export CARGO_HOME="$CARGO_DIR"
    export RUSTUP_TOOLCHAIN="$OPR_VERSION"
    export PATH="$CARGO_HOME/bin:$PATH"
fi
