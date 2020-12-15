#!/usr/bin/env bash

SOURCE_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")"; pwd`
DOCKERFILE_PATH=$SOURCE_DIR/30-devpi-dockerfile
IMAGE_NAME=devpi:python37

docker build --tag "${IMAGE_NAME}" --file "${DOCKERFILE_PATH}" "${SOURCE_DIR}"

