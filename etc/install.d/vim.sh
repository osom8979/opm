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
VIM_SNIP_DIR=$VIM_DIR/snippets

SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_VIM_DIR=$OPM_HOME/etc/vim/vim
SRC_VIM_SNIP_DIR=$SRC_VIM_DIR/snippets

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

## Create vimrc file.
echo '"== BEGIN OSOM VIM SETTING =='    >> $VIMRC
echo "scriptencoding utf-8"             >> $VIMRC
echo "source $SRC_VIM_DIR/plugin.vim"   >> $VIMRC
echo "source $SRC_VIM_DIR/config.vim"   >> $VIMRC
echo "source $SRC_VIM_DIR/keymap.vim"   >> $VIMRC
echo "source $SRC_VIM_DIR/macro.vim"    >> $VIMRC
echo '"== END OSOM VIM SETTING =='      >> $VIMRC

## NeoVim.
NEOVIM_HOME=$HOME/.config/nvim
NEOVIMRC=$NEOVIM_HOME/init.vim
mkdirs "$NEOVIM_HOME"
if [[ -f $NEOVIMRC ]]; then
    mv $NEOVIMRC $NEOVIMRC.$BACKUP_SUFFIX
fi
cp $VIMRC $NEOVIMRC

echo ''
echo 'Run this code:'
echo ''
echo ' vim +NeoBundleInstall +qall'
echo ''

