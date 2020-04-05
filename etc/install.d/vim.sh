#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    print_error 'Not defined OPM_HOME variable.'
    exit 1
fi
if [[ $VIA_INSTALLATION_SCRIPT -ne 1 ]]; then
    print_error 'You have to do it through the installation script.'
    exit 1
fi

AUTOMATIC_YES_FLAG=${AUTOMATIC_YES_FLAG:-0}
INSTALL_VARIABLE_VIM_BUNDLES=$INSTALL_VARIABLE_VIM_BUNDLES

function install_vimrc
{
    local source_file=$1
    local install_file=$2

    rm "$install_file"
    echo '"== BEGIN OSOM VIM SETTING ==' >> $install_file
    echo "scriptencoding utf-8"          >> $install_file
    echo "source $source_file"           >> $install_file
    echo '"== END OSOM VIM SETTING =='   >> $install_file
    print_information "Install vimrc: $install_file"
}

VIMRC=$HOME/.vimrc
VIM_DIR=$HOME/.vim
IDEAVIMRC=$HOME/.ideavimrc
SRC_VIMRC=$OPM_HOME/etc/vim/vimrc
SRC_IDEAVIMRC=$OPM_HOME/etc/vim/ideavimrc
NEOVIM_HOME=$HOME/.config/nvim
NEOVIMRC=$NEOVIM_HOME/init.vim
BUNDLE_DIR=$HOME/.vim/bundle
NEOBUNDLE_DIR=$BUNDLE_DIR/neobundle.vim

mkdirs "$BUNDLE_DIR"
mkdirs "$NEOVIM_HOME"

backup_file "$VIMRC"
backup_file "$IDEAVIMRC"
backup_file "$NEOVIMRC"

## Install NeoBundle.vim plugin.
if [[ -d "$NEOBUNDLE_DIR/.git" ]]; then
    print_warning "Exists $NEOBUNDLE_DIR"
else
    git clone "https://github.com/Shougo/neobundle.vim" "$NEOBUNDLE_DIR"
fi

install_vimrc "$SRC_VIMRC"     "$VIMRC"
install_vimrc "$SRC_IDEAVIMRC" "$IDEAVIMRC"
install_vimrc "$SRC_VIMRC"     "$NEOVIMRC"

## Install bundles.
yes_or_no_question "Install bundles?" INSTALL_VARIABLE_VIM_BUNDLES
if [[ $INSTALL_VARIABLE_VIM_BUNDLES -eq 1 ]]; then
    vim +NeoBundleInstall +qall
fi

