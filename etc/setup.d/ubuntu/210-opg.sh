#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v go &> /dev/null; then
    opm-init-opg

    if ! command -v go &> /dev/null; then
        echo "Not found go command" 1>&2
        exit 1
    fi
fi

PACKAGES=(
    golang.org/x/tools/cmd/goimports@latest
    google.golang.org/protobuf/cmd/protoc-gen-go@latest
    honnef.co/go/tools/cmd/staticcheck@latest
)

for pkg in "${PACKAGES[@]}"; do
    go install "$pkg"
done
