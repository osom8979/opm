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
    # fuse libfuse2 -- Installing on Ubuntu 24.04 causes Gnome Desktop to not display. Use fuse3 instead.
    fzf
    git
    gnome-control-center
    htop
    language-pack-ko
    libsecret-1-dev
    lsof
    neovim
    net-tools
    network-manager
    nmap
    shellcheck
    tmux
)

apt-get -y install "${PACKAGES[@]}"
