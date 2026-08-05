#!/usr/bin/env bash

docker run --rm --gpus all ubuntu:latest nvidia-smi "$@"
