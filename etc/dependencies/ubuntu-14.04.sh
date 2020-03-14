#!/bin/bash

## Compiler & tools.
apt-get install -y \
    yasm gfortran git cmake build-essential \
    autoconf automake libtool pkg-config texinfo \
    valgrind cppcheck doxygen

## Python
apt-get install -y python-dev python-pip

## FFmpeg dependency.
apt-get install -y \
    libass-dev libfreetype6-dev \
    libsdl1.2-dev libtheora-dev \
    libva-dev libvdpau-dev \
    libvorbis-dev libxcb1-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev \
    zlib1g-dev libx264-dev \
    libfdk-aac-dev libmp3lame-dev \
    libopus-dev libvpx-dev

## OpenCV 3.x dependency.
apt-get install -y \
    build-essential pkg-config \
    libgtk2.0-dev libavcodec-dev \
    libavformat-dev libswscale-dev \
    python-dev python-numpy libtbb2 \
    libtbb-dev libjpeg-dev libpng-dev \
    libtiff-dev libjasper-dev libdc1394-22-dev

## libGL.so
apt-get install -y libgl1-mesa-dri

## Vim editor.
apt-get install -y vim vim-gtk exuberant-ctags cscope
#vim +NeoBundleInstall +qall

## Graphics.
apt-get install -y imagemagick comix gimp

## Internet.
apt-get install firefox

## Themes & Tweaks.
apt-get install -y \
    unity-tweak-tool ibus-hangul \
    compizconfig-settings-manager

## Accessories.
apt-get install -y speedcrunch

## Font.
apt-get install -y fonts-nanum

## System.
apt-get install -y nautilus-open-terminal

## Caffe.
apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler
apt-get install -y --no-install-recommends libboost-all-dev
apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev
apt-get install -y libatlas-base-dev libopenblas-dev
#git clone https://github.com/BVLC/caffe
#pip install Cython numpy scipy scikit-image matplotlib ipython
#pip install h5py leveldb networkx nose pandas python-dateutil protobuf python-gflags pyyaml Pillow
#pip install easydict

