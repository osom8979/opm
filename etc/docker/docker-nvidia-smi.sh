#!/usr/bin/env bash

# Ubuntu 18.04
#  10.1-base, 10.1-base-ubuntu18.04 (10.1/base/Dockerfile)
#  10.1-runtime, 10.1-runtime-ubuntu18.04 (10.1/runtime/Dockerfile)
#  10.1-cudnn7-runtime, 10.1-cudnn7-runtime-ubuntu18.04 (10.1/runtime/cudnn7/Dockerfile)
#  latest, 10.1-devel, 10.1-devel-ubuntu18.04 (10.1/devel/Dockerfile)
#  10.1-cudnn7-devel, 10.1-cudnn7-devel-ubuntu18.04 (10.1/devel/cudnn7/Dockerfile)

# Test nvidia-smi with the latest official CUDA image
docker run --gpus all --rm nvidia/cuda:10.1-cudnn7-devel nvidia-smi

