#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v fallocate &> /dev/null; then
    echo "Not found fallocate command" 1>&2
    exit 1
fi

if ! command -v mkswap &> /dev/null; then
    echo "Not found mkswap command" 1>&2
    exit 1
fi

if ! command -v swapon &> /dev/null; then
    echo "Not found swapon command" 1>&2
    exit 1
fi

SWAPFILE_PATH="/swapfile"
if [[ -f "$SWAPFILE_PATH" ]]; then
    echo "Swap file already exists: $SWAPFILE_PATH" 1>&2
    exit 1
fi

MEM_SIZE=$(free -g | grep '^Mem' | awk '{print $2}')
CPU_COUNT=$(grep -c processor /proc/cpuinfo)

# https://access.redhat.com/ko/solutions/744483
if [[ $CPU_COUNT -ge 140 || $MEM_SIZE -ge 3072 ]]; then
    SWAP_SIZE="100G"
else
    if [[ $MEM_SIZE -eq 0 ]]; then
        SWAP_SIZE="2G"
    elif [[ $MEM_SIZE -lt 2 ]]; then
        SWAP_SIZE="$(( MEM_SIZE * 2 ))G"
    elif [[ $MEM_SIZE -lt 8 ]]; then
        SWAP_SIZE="${MEM_SIZE}G"
    elif [[ $MEM_SIZE -lt 64 ]]; then
        SWAP_SIZE="$(( MEM_SIZE / 2 ))G"
    else
        SWAP_SIZE="4G"
    fi
fi

read -r -e -i "$SWAP_SIZE" \
    -p "Please enter the swapfile size: " \
    SWAP_SIZE

fallocate --verbose -l "$SWAP_SIZE" "$SWAPFILE_PATH"
chmod --verbose 600 "$SWAPFILE_PATH"
mkswap --verbose "$SWAPFILE_PATH"

read -r -p "Enable swapfile? (y/N) " ANSWER
if [[ "$ANSWER" =~ ^[yY]$ ]]; then
    swapon --verbose "$SWAPFILE_PATH"
fi

# Display swap usage summary by device.
swapon -s

FSTAB_PATH="/etc/fstab"
FSTAB_ANSWER=n

read -r -p "Do you want to register a swap file in fstab? (y/N) " FSTAB_ANSWER

if [[ "$FSTAB_ANSWER" =~ ^[yY]$ ]]; then
    if [[ ! -f "$FSTAB_PATH" ]]; then
        echo "Fstab file not found: $FSTAB_PATH" 1>&2
        exit 1
    fi

    {
        echo "## Swap file created on $(date '+%Y%m%d_%H%M%S')"
        echo "/swapfile    none    swap    sw    0    0"
        echo "#########################################"
    } >> "$FSTAB_PATH"
fi
