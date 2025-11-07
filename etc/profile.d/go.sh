#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

USER_NAME=$(id -u -n)

OPG_VERSION=${OPG_VERSION:-$(opm-variable OPG_VERSION)}
OPG_ENVIRON=${OPG_ENVIRON:-$(opm-variable OPG_ENVIRON)}

KERNEL_NAME=$(opm-distribution --kernel)
MACHINE_NAME=$(opm-distribution --machine)

if [[ "$MACHINE_NAME" == "x86_64" ]]; then
    MACHINE_NAME=amd64
fi

GOROOT_DIR_NAME="go${OPG_VERSION}.${KERNEL_NAME}-${MACHINE_NAME}"
GOPATH_DIR_NAME="opg-${USER_NAME}-${OPG_VERSION}-${OPG_ENVIRON}"

if [[ -d "$HOME/.go" ]]; then
    export GOROOT="$OPM_HOME/var/go/root/${GOROOT_DIR_NAME}/go"
    export GOPATH="$OPM_HOME/var/go/path/${GOPATH_DIR_NAME}"
    export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
fi
