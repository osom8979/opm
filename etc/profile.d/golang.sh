#!/usr/bin/env bash

if [[ -z $PROJECT_HOME ]]; then
PROJECT_HOME=$HOME/Project
fi

if [[ -z $GOPATH ]]; then
    GOPATH=$PROJECT_HOME/golang
    if [[ ! -d "$GOPATH" ]]; then
        mkdir -p "$GOPATH"
    fi
fi

export GOPATH

