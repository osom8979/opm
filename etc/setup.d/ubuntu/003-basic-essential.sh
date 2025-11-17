#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v apt-get &> /dev/null; then
    echo "Not found apt-get command" 1>&2
    exit 1
fi

PACKAGES=(
    build-essential
    ccls
    cmake
    curl
    fzf
    git
    language-pack-ko
    libsecret-1-dev
    neovim
    net-tools
    network-manager
    shellcheck
    tmux
    fuse
    libfuse2
)

apt-get -y install "${PACKAGES[@]}"
