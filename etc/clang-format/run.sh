#!/usr/bin/env bash

# clang-format -style=llvm     -dump-config > clang-format-llvm
# clang-format -style=google   -dump-config > clang-format-google
# clang-format -style=chromium -dump-config > clang-format-chromium
# clang-format -style=mozilla  -dump-config > clang-format-mozilla
# clang-format -style=webkit   -dump-config > clang-format-webkit

FLAGS="-i"

clang-format $FLAGS -style=clang-format-osom test.cpp

