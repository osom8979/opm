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
    conky
    ffmpeg
    gimp
    imagemagick
    inkscape
    mplayer
    remmina
    simplescreenrecorder
    speedcrunch
    vlc
)

apt-get -y install "${PACKAGES[@]}"
