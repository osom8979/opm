#!/usr/bin/env bash

function getAbsoluteDirectory {
    local working=$PWD
    cd "$(dirname $1)"
    echo $PWD
    cd "$working"
}

WORKING=$PWD
SCRIPT_DIR=`getAbsoluteDirectory "${BASH_SOURCE[0]}"`

LLDB_COMMAND=${1:-lldb}
NVIM_SOCKET_PATH=$2

LLDB_INIT_PATH=`mktemp /tmp/opvim_lldb_init.XXXXXX`
cat > $LLDB_INIT_PATH <<EOF
command script import $SCRIPT_DIR/lldb_script.py
command script add -f lldb_script.init opvim-lldb-init
opvim-lldb-init $NVIM_SOCKET_PATH
EOF

