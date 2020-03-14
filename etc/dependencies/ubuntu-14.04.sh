#!/bin/bash

## Compiler & tools.
apt-get install yasm
apt-get install gfortran
apt-get install git
apt-get install cmake
apt-get install build-essential
apt-get install autoconf automake libtool
apt-get install pkg-config texinfo
apt-get install valgrind cppcheck
apt-get install doxygen

## Python
apt-get install python-dev python-pip

## FFmpeg dependency.
apt-get install libass-dev libfreetype6-dev
apt-get install libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev
apt-get install libxcb-xfixes0-dev zlib1g-dev
apt-get install libx264-dev
apt-get install libfdk-aac-dev
apt-get install libmp3lame-dev
apt-get install libopus-dev
apt-get install libvpx-dev

## OpenCV 3.x dependency.
apt-get install build-essential
apt-get install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
apt-get install python-dev python-numpy libtbb2 libtbb-dev
apt-get install libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

## libGL.so
apt-get install libgl1-mesa-dri

## Vim editor.
apt-get install vim
apt-get install vim-gtk
apt-get install exuberant-ctags cscope
#vim +NeoBundleInstall +qall

## Graphics.
apt-get install imagemagick
apt-get install comix
apt-get install gimp

## Internet.
apt-get install firefox

## Themes & Tweaks.
apt-get install unity-tweak-tool
apt-get install ibus-hangul
apt-get install compizconfig-settings-manager

## Accessories.
apt-get install speedcrunch

## Font.
apt-get install fonts-nanum

## System.
apt-get install nautilus-open-terminal

## Caffe.
apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler
apt-get install --no-install-recommends libboost-all-dev
apt-get install libgflags-dev libgoogle-glog-dev liblmdb-dev
apt-get install libatlas-base-dev libopenblas-dev
#git clone https://github.com/BVLC/caffe
#pip install Cython numpy scipy scikit-image matplotlib ipython
#pip install h5py leveldb networkx nose pandas python-dateutil protobuf python-gflags pyyaml Pillow
#pip install easydict

