#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Not found curl command" 1>&2
    exit 1
fi

NVIM_PATH=/usr/local/bin/nvim

# NVIM_VERSION=v0.9.5
NVIM_VERSION=latest

if [[ "$NVIM_VERSION" == "latest" ]]; then
URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
else
URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"
fi

if [[ -f "$NVIM_PATH" ]]; then
    echo "Exists output file path: $NVIM_PATH"
    echo "Please delete the file before continuing."
    exit 1
fi

curl -L -k -o "$NVIM_PATH" "$URL"

if [[ -f "$NVIM_PATH" && ! -x "$NVIM_PATH" ]]; then
    chmod -v +x "$NVIM_PATH"
fi
