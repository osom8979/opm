#!/usr/bin/env bash

if [[ -z $GOPATH ]]; then
    GOPATH=$HOME/Project/golang
    if [[ ! -d "$GOPATH" ]]; then
        mkdir -p "$GOPATH"
    fi
fi

export GOPATH

