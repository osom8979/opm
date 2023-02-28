#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    print_error 'Not defined OPM_HOME variable.'
    exit 1
fi

VIMRC=$HOME/.vimrc
IDEAVIMRC=$HOME/.ideavimrc

SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_IDEAVIMRC=$OPM_HOME/etc/vim/ideavimrc

NEOVIM_DIR=$HOME/.config/nvim
NEOVIMRC=$NEOVIM_DIR/init.vim

if [[ -e "$VIMRC" ]]; then
    echo "The vimrc file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $VIMRC" 1>&2
    exit 1
fi
if [[ -e "$IDEAVIMRC" ]]; then
    echo "The ideavimrc file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $IDEAVIMRC" 1>&2
    exit 1
fi
if [[ -e "$NEOVIMRC" ]]; then
    echo "The neovimrc file already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $NEOVIMRC" 1>&2
    exit 1
fi

if [[ ! -d "$NEOVIM_DIR" ]]; then
    mkdir -vp "$NEOVIM_DIR"
fi

function install_vimrc
{
    local src=$1
    local dest=$2

    {
        echo "\"== BEGIN OSOM VIM SETTING =="
        echo "scriptencoding utf-8"
        echo "source $src"
        echo "\"== END OSOM VIM SETTING =="
    } >> "$dest"
}

install_vimrc "$SRC_VIMRC" "$VIMRC"
install_vimrc "$SRC_IDEAVIMRC" "$IDEAVIMRC"
install_vimrc "$SRC_VIMRC" "$NEOVIMRC"
