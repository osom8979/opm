#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

function mkdirs {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi
}

VIMRC=$HOME/.vimrc
VIM_DIR=$HOME/.vim

SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_VIM_DIR=$OPM_HOME/etc/vim/vim

DATE_FORMAT=`date +%Y%m%d_%H%M%S`
BACKUP_SUFFIX=$DATE_FORMAT.backup

## Backup.
if [[ -f $VIMRC ]]; then
    mv $VIMRC $VIMRC.$BACKUP_SUFFIX
fi

## Install NeoBundle.vim plugin.
BUNDLE_DIR=$HOME/.vim/bundle
NEOBUNDLE_DIR=$BUNDLE_DIR/neobundle.vim
mkdirs "$BUNDLE_DIR"
if [[ -d "$NEOBUNDLE_DIR/.git" ]]; then
    echo 'Exists $NEOBUNDLE_DIR'
else
    git clone https://github.com/Shougo/neobundle.vim $NEOBUNDLE_DIR
fi

## Create a symbolic link.
ln -s $SRC_VIMRC $VIMRC
ln -s $SRC_VIM_DIR/config.vim  $VIM_DIR/config.vim
ln -s $SRC_VIM_DIR/keymap.vim  $VIM_DIR/keymap.vim
ln -s $SRC_VIM_DIR/macro.vim   $VIM_DIR/macro.vim
ln -s $SRC_VIM_DIR/plugin.vim  $VIM_DIR/plugin.vim
ln -s $SRC_VIM_DIR/ycm_conf.py $VIM_DIR/ycm_conf.py

## NeoVim.
NEOVIM_HOME=$HOME/.config/nvim
NEOVIMRC=$NEOVIM_HOME/init.vim
mkdirs "$NEOVIM_HOME"
ln -s $SRC_VIMRC $NEOVIMRC

echo ''
echo 'Run this code:'
echo ''
echo ' vim +NeoBundleInstall +qall'
echo ''

