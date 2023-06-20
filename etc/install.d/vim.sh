#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPCODE=${1:-install}
FORCE=${FORCE:-0}
AUTOMATIC_YES=${AUTOMATIC_YES:-0}
IFS=" " read -r -a VFI_FLAGS <<< "${VFI_FLAGS:--v}"

VIMRC=$HOME/.vimrc
IDEAVIMRC=$HOME/.ideavimrc

SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_IDEAVIMRC=$OPM_HOME/etc/vim/ideavimrc

NEOVIM_DIR=$HOME/.config/nvim
NEOVIMRC=$NEOVIM_DIR/init.vim

function install_vimrc
{
    local name=$1
    local src=$2
    local dest=$3

    if [[ $FORCE -eq 0 && -e "$dest" ]]; then
        echo "The $name file already exists" 1>&2
        echo "Delete the file to continue installation" 1>&2
        echo " $dest" 1>&2
        exit 1
    fi

    local install_dir
    if ! install_dir="$(dirname "$dest")"; then
        install_dir=${dest%/*}
    fi

    if [[ ! -d "$install_dir" ]]; then
        mkdir -vp "$install_dir"
    fi

    {
        echo "\"== BEGIN OSOM VIM SETTING =="
        echo "scriptencoding utf-8"
        echo "source $src"
        echo "\"== END OSOM VIM SETTING =="
    } >> "$dest"
}

function install
{
    install_vimrc "vimrc" "$SRC_VIMRC" "$VIMRC"
    install_vimrc "ideavimrc" "$SRC_IDEAVIMRC" "$IDEAVIMRC"
    install_vimrc "neovimrc" "$SRC_VIMRC" "$NEOVIMRC"
}

function uninstall
{
    rm "${VFI_FLAGS[@]}" "$VIMRC"
    rm "${VFI_FLAGS[@]}" "$IDEAVIMRC"
    rm "${VFI_FLAGS[@]}" "$NEOVIMRC"
}

if [[ $OPCODE == "install" ]]; then
    install
elif [[ $OPCODE == "uninstall" ]]; then
    uninstall
fi
