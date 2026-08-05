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

case "$(uname -m)" in
x86_64 | amd64)
    NVIM_ARCH=x86_64
    ;;
aarch64 | arm64)
    NVIM_ARCH=arm64
    ;;
*)
    echo "Unsupported architecture: $(uname -m)" 1>&2
    exit 1
    ;;
esac

# The architecture suffix was introduced in v0.10.4.
# Older releases provide a single 'nvim.appimage' built for x86_64 only.
if [[ "$NVIM_VERSION" == "latest" ]]; then
URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.appimage"
else
URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.appimage"
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
