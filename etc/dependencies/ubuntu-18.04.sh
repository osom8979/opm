#!/usr/bin/env bash

## Update
apt-get update
apt-get upgrade

## Themes & Tweaks
apt-get install -y gnome-tweak-tool
apt-get install -y gnome-shell-extension-system-monitor

## Network
apt-get install -y net-tools

## Compiler
apt-get install -y yasm nasm gfortran git cmake build-essential

## Developer tools
apt-get install -y valgrind cppcheck doxygen

## Vim editor
apt-get install -y neovim
apt-get install -y exuberant-ctags cscope
vim +NeoBundleInstall +qall

## Graphics
apt-get install -y imagemagick comix gimp

## Utilities
apt-get install -y speedcrunch

