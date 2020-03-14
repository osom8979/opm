#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX
check_variable_or_exit PLATFORM

PROTOCOL=https
HOST_NAME="nexus.bogo.local"
PORT_NUMBER=8080
REQUEST_HOST="$HOST_NAME:$PORT_NUMBER"
REPO_PATH=repository/bogo-tbag
REPO_PREFIX="${PROTOCOL}://${HOST_NAME}:${PORT_NUMBER}/${REPO_PATH}"

FILE_DARWIN="c2core-prerequisite-Darwin-20190618_110346.tar.gz"
MD5_DARWIN=5bb26af9d4f99c5eb0806e1e781e1fc0

FILE_LINUX="c2core-prerequisite-Linux-20190618_093745.tar.gz"
MD5_LINUX=0face6ad7137d9f445e0a8bb85e4492c

case "$PLATFORM" in
Darwin)
    NAME=${FILE_DARWIN}
    MD5=${MD5_DARWIN}
    ;;
Linux)
    NAME=${FILE_LINUX}
    MD5=${MD5_LINUX}
    ;;
*)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

URL="${REPO_PREFIX}/${NAME}"

HOST_IP=`cat /etc/hosts | grep ${HOST_NAME} | awk '{print $1}'`
if [[ -z $HOST_IP ]]; then
    print_error "Not found host ip: ${HOST_NAME}"
    exit 1
fi

DOWNLOAD_FILE="$BUILD_DIR/$NAME"
if [[ ! -f "$DOWNLOAD_FILE" ]]; then
    read    -p "Repo user id: " USER_ID
    read -s -p "Repo user pw: " USER_PW
    print_message ' '
    download "$DOWNLOAD_FILE" "$URL" -u "${USER_ID}:${USER_PW}"
else
    print_message "Exists file: $DOWNLOAD_FILE"
fi

checksum_or_exit "$DOWNLOAD_FILE" "$MD5"
extract "$DOWNLOAD_FILE" "$PREFIX"

