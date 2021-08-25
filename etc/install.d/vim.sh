#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    print_error 'Not defined OPM_HOME variable.'
    exit 1
fi
if [[ $VIA_INSTALLATION_SCRIPT -ne 1 ]]; then
    print_error 'You have to do it through the installation script.'
    exit 1
fi

WHICH_NVIM=`which nvim 2> /dev/null`
WHICH_VIM=`which vim 2> /dev/null`
WHICH_VI=`which vi 2> /dev/null`

if [[ -n "$WHICH_NVIM" ]]; then
    VIM_CMD=$WHICH_NVIM
elif [[ -n "$WHICH_VIM" ]]; then
    VIM_CMD=$WHICH_VIM
elif [[ -n "$WHICH_VI" ]]; then
    VIM_CMD=$WHICH_VI
else
    print_error 'Not found vim executable.'
fi

AUTOMATIC_YES_FLAG=${AUTOMATIC_YES_FLAG:-0}
INSTALL_VARIABLE_VIM_BUNDLES=$INSTALL_VARIABLE_VIM_BUNDLES

VIMRC=$HOME/.vimrc
VIM_DIR=$HOME/.vim
IDEAVIMRC=$HOME/.ideavimrc
SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_IDEAVIMRC=$OPM_HOME/etc/vim/ideavimrc
NEOVIM_HOME=$HOME/.config/nvim
NEOVIMRC=$NEOVIM_HOME/init.vim
BUNDLE_DIR=$HOME/.vim/bundle
NEOBUNDLE_DIR=$BUNDLE_DIR/neobundle.vim
NEOBUNDLE_URL=https://github.com/Shougo/neobundle.vim

mkdirs "$BUNDLE_DIR"
mkdirs "$NEOVIM_HOME"

backup_file "$VIMRC"
backup_file "$IDEAVIMRC"
backup_file "$NEOVIMRC"

## Install NeoBundle.vim plugin.
if [[ -d "$NEOBUNDLE_DIR/.git" ]]; then
    print_warning "Exists $NEOBUNDLE_DIR"
else
    WHICH_GIT=`which git 2> /dev/null`
    if [[ -n "$WHICH_GIT" ]]; then
        "$WHICH_GIT" clone "$NEOBUNDLE_URL" "$NEOBUNDLE_DIR"
    else
        print_warning 'Not found git executable.'
    fi
fi

function install_vimrc
{
    local source_file=$1
    local install_file=$2

    remove_file "$install_file"
    echo '"== BEGIN OSOM VIM SETTING ==' >> $install_file
    echo "scriptencoding utf-8"          >> $install_file
    echo "source $source_file"           >> $install_file
    echo '"== END OSOM VIM SETTING =='   >> $install_file
    print_information "Install vimrc: $install_file"
}

install_vimrc "$SRC_VIMRC"     "$VIMRC"
install_vimrc "$SRC_IDEAVIMRC" "$IDEAVIMRC"
install_vimrc "$SRC_VIMRC"     "$NEOVIMRC"

