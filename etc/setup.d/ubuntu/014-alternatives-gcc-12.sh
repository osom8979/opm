#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v update-alternatives &> /dev/null; then
    echo "Not found update-alternatives command" 1>&2
    exit 1
fi

apt-get install gcc-12 g++-12

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120

update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 110
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 120

update-alternatives --install /usr/bin/cc  cc  /usr/bin/gcc    999
update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++    999

update-alternatives --set cc  /usr/bin/gcc
update-alternatives --set c++ /usr/bin/g++
