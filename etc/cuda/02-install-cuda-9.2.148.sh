#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    echo " sudo $0"
    exit 1
fi

if [[ "$(lsb_release -si)" != "Ubuntu" ]]; then
    echo 'Unsupported distribution.'
    exit 1
fi

case "$(uname -s)" in
Darwin)
    MD5_CMD='md5 -r'
    ;;
#Linux)
#CYGWIN*|MINGW*|MSYS*)
*)
    MD5_CMD='md5sum'
    ;;
esac

echo 'Download CUDA Toolkit'
echo 'CUDA Version: 9.2.148'

CUDA_BASE_URL='https://developer.nvidia.com/compute/cuda/9.2/Prod2/local_installers/cuda_9.2.148_396.37_linux'
CUDA_PATCH_URL='https://developer.nvidia.com/compute/cuda/9.2/Prod2/patches/1/cuda_9.2.148.1_linux'

CUDA_BASE_NAME='cuda_9.2.148_396.37_linux.run'
CUDA_PATCH_NAME='cuda_9.2.148.1_linux.run'

CUDA_BASE_MD5=8303cdf46904e6dea8d5d641b0b46f0d
CUDA_PATCH_MD5=48cced8344f5c93e0e60f16875256051

function check_and_download_file {
    local msg=$1
    local name=$2
    local url=$3
    local md5=$4

    local md5_result=`$MD5_CMD $name`
    local checksum=`echo $md5_result | awk '{print($1);}'`

    if [[ -f "$name" ]]; then
        if [[ "$checksum" == "$md5" ]]; then
            echo "Exists $msg, checksum ok: $checksum"
        else
            echo "Checksum $msg, error: $checksum != $md5"
            exit 1
        fi
    else
        echo "Download $msg ..."
        curl -L -o "$name" "$url"

        local md5_result=`$MD5_CMD $name`
        local checksum=`echo $md5_result | awk '{print($1);}'`

        if [[ "$checksum" == "$md5" ]]; then
            chmod +x "$name"
        else
            echo "Checksum $msg, error: $checksum != $md5"
            exit 1
        fi
    fi
}

function check_command {
    if [[ -z $(which $1) ]]; then
        echo "Not found $1 command"
        exit 1
    fi
}

#apt-get update
#apt-get install -y curl bzip2 gcc g++ build-essential
check_command curl
check_command bzip2
check_command gcc
check_command g++
check_command make

check_and_download_file "Base installer" "$CUDA_BASE_NAME" "$CUDA_BASE_URL" "$CUDA_BASE_MD5"
check_and_download_file "Patch 1 (Released Aug 6, 2018)" "$CUDA_PATCH_NAME" "$CUDA_PATCH_URL" "$CUDA_PATCH_MD5"

LIGHTDM_STATUS=`service --status-all | grep lightdm`
GDM3_STATUS=`service --status-all | grep gdm3`

if [[ "$LIGHTDM_STATUS" != "" ]]; then
    echo 'Stop lightdm ...'
    service lightdm stop
fi

if [[ "$GDM3_STATUS" != "" ]]; then
    echo 'Stop gdm3 ...'
    service lightdm gdm3
fi

echo "Run $CUDA_BASE_NAME"
"$CUDA_BASE_NAME" --silent --driver --toolkit --samples --run-nvidia-xconfig

echo "Run $CUDA_PATCH_NAME"
"$CUDA_PATCH_NAME" --silent --accept-eula

echo 'Done.'

