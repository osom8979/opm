#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v nvim &> /dev/null; then
    echo "Not found nvim executable" 1>&2
    exit 1
fi


ARGS=(
    -u "$HOME/.config/nvim/init.vim"
    -c "try | UpdateRemotePlugins | finally | qall! | endtry"
    -V1
    -es
)

nvim "${ARGS[@]}" 2>&1 | grep -v "^not found in"
echo -n -e "\n"
