#!/bin/bash

## Compiler & tools.
sudo apt-get install yasm
sudo apt-get install gfortran
sudo apt-get install git
sudo apt-get install cmake
sudo apt-get install build-essential
sudo apt-get install autoconf automake libtool
sudo apt-get install pkg-config texinfo
sudo apt-get install valgrind cppcheck
sudo apt-get install doxygen

## Python
sudo apt-get install python-dev python-pip
sudo -H pip install youtube-dl

## FFmpeg dependency.
sudo apt-get install libass-dev libfreetype6-dev
sudo apt-get install libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev
sudo apt-get install libxcb-xfixes0-dev zlib1g-dev
sudo apt-get install libx264-dev
sudo apt-get install libfdk-aac-dev
sudo apt-get install libmp3lame-dev
sudo apt-get install libopus-dev
sudo apt-get install libvpx-dev

## OpenCV 3.x dependency.
sudo apt-get install build-essential
sudo apt-get install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev
sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

## libGL.so
sudo apt-get install libgl1-mesa-dri

## Vim editor.
sudo apt-get install vim
sudo apt-get install vim-gtk
sudo apt-get install exuberant-ctags cscope
#vim +NeoBundleInstall +qall

## Graphics.
sudo apt-get install imagemagick
sudo apt-get install comix
sudo apt-get install gimp

## Internet.
sudo apt-get install firefox

## Themes & Tweaks.
sudo apt-get install unity-tweak-tool
sudo apt-get install ibus-hangul
sudo apt-get install compizconfig-settings-manager

## Accessories.
sudo apt-get install speedcrunch

## Font.
sudo apt-get install fonts-nanum

## System.
sudo apt-get install nautilus-open-terminal

## Caffe.
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler
sudo apt-get install --no-install-recommends libboost-all-dev
sudo apt-get install libgflags-dev libgoogle-glog-dev liblmdb-dev
sudo apt-get install libatlas-base-dev libopenblas-dev
#git clone https://github.com/BVLC/caffe
sudo -H pip install Cython numpy scipy scikit-image matplotlib ipython
sudo -H pip install h5py leveldb networkx nose pandas python-dateutil protobuf python-gflags pyyaml Pillow
sudo -H pip install easydict

