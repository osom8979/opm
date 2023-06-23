#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

function print_error
{
    # shellcheck disable=SC2145
    echo -e "\033[31m$@\033[0m" 1>&2
}

function print_message
{
    # shellcheck disable=SC2145
    echo -e "\033[32m$@\033[0m"
}

if ! command -v 7za &> /dev/null; then
    print_error "Not found '7za' command"
    print_error "Please run the following command:"
    print_error "  sudo apt install p7zip-full"
    exit 1
fi

read -s -r -p "Enter a archive password: " PASS
echo -n -e "\n"
read -s -r -p "Re-enter a archive password: " REPASS

if [[ -z $PASS || "$PASS" != "$REPASS" ]]; then
    print_error "Incorrect password error"
    exit 1
fi

DATE_FORMAT=$(date +%Y%m%d)

print_message "Images backup starts ..."
time 7za a "images-$DATE_FORMAT.7z" images/ -p"$PASS"
CODE=$?
if [[ $CODE -ne 0 ]]; then
    print_error "Images backup failed: $CODE"
    exit $CODE
fi

print_message "Database backup starts ..."
time 7za a -p"$PASS" "mysql-$DATE_FORMAT.7z" mysql/
CODE=$?
if [[ $CODE -ne 0 ]]; then
    print_error "Database backup failed: $CODE"
    exit $CODE
fi
