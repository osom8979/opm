#!/usr/bin/env bash

WORKING=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$WORKING/__config__"

check_variable_or_exit PREFIX

PIP_CMD="$PREFIX/bin/pip3"
if [[ ! -x "$PIP_CMD" ]]; then
    print_error "Not found $PIP_CMD"
    exit 1
fi

"$PIP_CMD" install --no-cache-dir --upgrade pip

PACKAGE_LIST="${PACKAGE_LIST} cython numpy"  ## basic
PACKAGE_LIST="${PACKAGE_LIST} opencv-python flask pycocotools"  ## recommand
PACKAGE_LIST="${PACKAGE_LIST} ninja yacs matplotlib tqdm"  ## maskrcnn-benchmark requirements
PACKAGE_LIST="${PACKAGE_LIST} cxxfilt PyYAML pytest"  ## apex requirements
PACKAGE_LIST="${PACKAGE_LIST} aiohttp[speedups] psycopg2-binary"  ## c2central requirements
PACKAGE_LIST="${PACKAGE_LIST} jupyterlab"

# pillow pandas scipy sklearn scikit-image pynng trio tensorboardX
# colorlog h5py lmdb wxPython numba urllib3 colorama fire shapely onnx pycuda wget

for i in ${PACKAGE_LIST}; do
    print_message "Install $i"
    "$PIP_CMD" install --no-cache-dir $i
done

