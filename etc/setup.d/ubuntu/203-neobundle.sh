#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Not found git executable" 1>&2
    exit 1
fi

if ! command -v nvim &> /dev/null; then
    echo "Not found nvim executable" 1>&2
    exit 1
fi

URL=https://github.com/Shougo/neobundle.vim
DEST=$HOME/.vim/bundle/neobundle.vim

if [[ -d "$DEST/.git" ]]; then
    git --work-tree="$DEST" --git-dir="$DEST/.git" pull origin master
else
    if [[ ! -d "$DEST" ]]; then
        mkdir -vp "$DEST"
    fi
    git clone "$URL" "$DEST"
fi

ARGS=(
    -N  # No-compatible mode
    -u "$HOME/.vimrc"
    -c "try | NeoBundleUpdate! | finally | qall! | endtry"
    -U NONE  # GUI initializations
    -i NONE  # viminfo file
    -V1 # Verbose level 1
    -e  # Start Vim in Ex mode
    -s  # Silent mode
)

nvim "${ARGS[@]}" 2>&1 | grep -v "^not found in"
echo -n -e "\n"
