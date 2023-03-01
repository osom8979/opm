#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
source "$SCRIPT_DIR/__config__"

check_variable_or_exit EXTERNAL_PREFIX
exists_program_or_exit git

git_sync "https://github.com/osom8979/external.git" "$EXTERNAL_PREFIX"

