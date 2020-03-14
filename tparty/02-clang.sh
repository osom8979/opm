#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit SYSTEM_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit PLATFORM

FILE_DARWIN="clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz"
URL_DARWIN="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz"
MD5_DARWIN=56f071bf50504346ccf2de4915a50f24

FILE_UBUNTU_14="clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz"
URL_UBUNTU_14="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz"
MD5_UBUNTU_14=a4b8dd079239d30b47103cefc36b2eaf

FILE_UBUNTU_16="clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz"
URL_UBUNTU_16="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz"
MD5_UBUNTU_16=54be66afe525a1fca539c3ef559fac80

FILE_UBUNTU_18="clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
URL_UBUNTU_18="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
MD5_UBUNTU_18=3137dad7c085b452b652143ef2a5df09

case "$PLATFORM" in
Darwin)
    FILE=${FILE_DARWIN}
    URL=${URL_DARWIN}
    MD5=${MD5_DARWIN}
    ;;
Linux)
    if [[ "$DISTRIBUTION" == "ubuntu" ]]; then
        case "$DISTRIBUTION_VERSION" in
        14)
            FILE=${FILE_UBUNTU_14}
            URL=${URL_UBUNTU_14}
            MD5=${MD5_UBUNTU_14}
            ;;
        16)
            FILE=${FILE_UBUNTU_16}
            URL=${URL_UBUNTU_16}
            MD5=${MD5_UBUNTU_16}
            ;;
        18)
            FILE=${FILE_UBUNTU_18}
            URL=${URL_UBUNTU_18}
            MD5=${MD5_UBUNTU_18}
            ;;
        *)
            print_error "Unsupported ubuntu version: $DISTRIBUTION_VERSION"
            exit 1
            ;;
        esac
    else
        print_error "Unsupported linux platform."
        exit 1
    fi
    ;;
*)
    print_error "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

checked_download "$SOURCE_PREFIX/$FILE" "$URL" "$MD5"
extract "$SOURCE_PREFIX/$FILE" "$SYSTEM_PREFIX" --strip 1

