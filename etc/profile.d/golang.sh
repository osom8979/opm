#!/bin/bash

if [[ -n "$GOPATH" ]]; then
    GOPATH=$HOME/Project/golang
    if [[ ! -d "$GOPATH" ]]; then
        mkdir -p "$GOPATH"
    fi
fi

export GOPATH

