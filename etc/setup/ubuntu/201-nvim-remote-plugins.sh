#!/usr/bin/env bash

if ! command -v git &> /dev/null; then
    echo "not found git executable" 1>&2
    exit 1
fi


ARGS=(
    -u "$HOME/.config/nvim/init.vim"
    -c "try | UpdateRemotePlugins! | finally | qall! | endtry"
    -V1
    -es
)

nvim "${ARGS[@]}" 2>&1
echo -n -e "\n"
