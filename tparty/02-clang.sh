#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit SYSTEM_PREFIX
check_variable_or_exit SOURCE_PREFIX
check_variable_or_exit PLATFORM

FILE_DARWIN="clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz"
URL_DARWIN="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz"
MD5_DARWIN=56f071bf50504346ccf2de4915a50f24

FILE_UBUNTU_1404="clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz"
URL_UBUNTU_1404="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz"
MD5_UBUNTU_1404=a4b8dd079239d30b47103cefc36b2eaf

FILE_UBUNTU_1604="clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz"
URL_UBUNTU_1604="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz"
MD5_UBUNTU_1604=54be66afe525a1fca539c3ef559fac80

FILE_UBUNTU_1804="clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
URL_UBUNTU_1804="http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
MD5_UBUNTU_1804=3137dad7c085b452b652143ef2a5df09

case "$PLATFORM" in
Darwin)
    FILE=${FILE_DARWIN}
    URL=${URL_DARWIN}
    MD5=${MD5_DARWIN}
    ;;
Linux)
    if [[ "$DISTRIBUTION" == "ubuntu" ]]; then
        case "$DISTRIBUTION_VERSION" in
        14.04)
            FILE=${FILE_UBUNTU_1404}
            URL=${URL_UBUNTU_1404}
            MD5=${MD5_UBUNTU_1404}
            ;;
        16.04)
            FILE=${FILE_UBUNTU_1604}
            URL=${URL_UBUNTU_1604}
            MD5=${MD5_UBUNTU_1604}
            ;;
        18.04)
            FILE=${FILE_UBUNTU_1804}
            URL=${URL_UBUNTU_1804}
            MD5=${MD5_UBUNTU_1804}
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

