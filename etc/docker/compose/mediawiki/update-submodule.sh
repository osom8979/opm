#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

git -C "$ROOT_DIR" submodule update --init ./SimpleMathJax
