#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

VIMRC=$HOME/.vimrc
VIM_DIR=$HOME/.vim

VIM_CONFIG=$VIM_DIR/config.vim
VIM_KEYMAP=$VIM_DIR/keymap.vim
VIM_MACRO=$VIM_DIR/macro.vim
VIM_PLUGIN=$VIM_DIR/plugin.vim
VIM_YCM_CONF=$VIM_DIR/ycm_conf.py

SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_VIM_DIR=$OPM_HOME/etc/vim/vim

SRC_VIM_CONFIG=$SRC_VIM_DIR/config.vim
SRC_VIM_KEYMAP=$SRC_VIM_DIR/keymap.vim
SRC_VIM_MACRO=$SRC_VIM_DIR/macro.vim
SRC_VIM_PLUGIN=$SRC_VIM_DIR/plugin.vim
SRC_VIM_YCM_CONF=$SRC_VIM_DIR/ycm_conf.py

DATE_FORMAT=`date +%Y%m%d_%H%M%S`
BACKUP_SUFFIX=$DATE_FORMAT.backup

## Backup.
if [[ -f $VIMRC ]]; then
    mv $VIMRC $VIMRC.$BACKUP_SUFFIX
fi

## Install Shougo/neobundle.vim plugin.
BUNDLE_DIR=$HOME/.vim/bundle
NEOBUNDLE_DIR=$BUNDLE_DIR/neobundle.vim
mkdir -p "$BUNDLE_DIR"
if [[ -d "$NEOBUNDLE_DIR/.git" ]]; then
    echo 'Exists $NEOBUNDLE_DIR'
else
    git clone https://github.com/Shougo/neobundle.vim $NEOBUNDLE_DIR
fi

## Create a symbolic link.
ln -s $SRC_VIMRC         $VIMRC
ln -s $SRC_VIM_CONFIG    $VIM_CONFIG
ln -s $SRC_VIM_KEYMAP    $VIM_KEYMAP
ln -s $SRC_VIM_MACRO     $VIM_MACRO
ln -s $SRC_VIM_PLUGIN    $VIM_PLUGIN
ln -s $SRC_VIM_YCM_CONF  $VIM_YCM_CONF

echo ''
echo 'Run this code:'
echo ''
echo ' vim +NeoBundleInstall +qall'
echo ''

