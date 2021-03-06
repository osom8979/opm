#!/usr/bin/env bash

## Update
apt-get update
apt-get upgrade -y

## Themes & Tweaks
apt-get install -y gnome-tweak-tool
apt-get install -y gnome-shell-extension-system-monitor \
    gnome-shell-extension-move-clock

## Network
apt-get install -y net-tools curl git

## Compiler
apt-get install -y yasm nasm gfortran cmake build-essential

## Developer tools
# cppcheck
apt-get install -y valgrind doxygen

## Vim editor
apt-get install -y neovim
apt-get install -y exuberant-ctags cscope
# vim +NeoBundleInstall +qall

# YouCompleteMe clang completer:
apt-get install -y llvm libpython-dev
# cd "$HOME/.vim/bundle/YouCompleteMe"
# git submodule update --init --recursive
# ./install.sh --clang-completer

## Graphics
# comix gimp
apt-get install -y imagemagick krita

## Multimedia
apt-get install -y vlc

## Utilities
apt-get install -y speedcrunch

## Indicators
apt-get install -y indicator-multiload

## Language support
apt-get install -y language-pack-ko \
    gnome-getting-started-docs-ko \
    firefox-locale-ko \
    gnome-user-docs-ko \
    hunspell-en-gb \
    hunspell-ko \
    language-pack-gnome-ko \
    ibus-hangul \
    hunspell-en-au \
    fonts-noto-cjk-extra \
    hunspell-en-ca \
    hunspell-en-za \
    kde-config-fcitx

## python-virtualenv
sudo apt-get install -y \
    make build-essential wget curl llvm \
    libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev \
    libncurses5-dev xz-utils tk-dev

