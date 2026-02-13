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
    # fuse libfuse2 -- Installing on Ubuntu 24.04 causes Gnome Desktop to not display. Use fuse3 instead.
    build-essential
    ccls
    cmake
    curl
    exuberant-ctags
    fzf
    git
    gnome-control-center
    htop
    language-pack-ko
    libsecret-1-dev
    lsof
    net-tools
    network-manager
    nmap
    podman
    postgresql-client
    shellcheck
    tmux
    xclip
)

apt-get -y install "${PACKAGES[@]}"
