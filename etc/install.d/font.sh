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
INSTALL_VARIABLE_FONT_UPDATE_CACHE=$INSTALL_VARIABLE_FONT_UPDATE_CACHE

NERD_FONT_SOURCE_DIR="$OPM_HOME/etc/font"
NERD_FONT_TITLE="DroidSansMono Nerd Font"
NERD_FONT_FILENAME="Droid Sans Mono Nerd Font Complete.otf"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"

KERNEL_NAME=`uname -s`
case $KERNEL_NAME in
Darwin)
    FONTS_INSTALL_DIR="$HOME/Library/Fonts"
    FONTS_INSTALLED=0
    ;;
Linux)
    FONTS_INSTALL_DIR="$HOME/.local/share/fonts"
    FONTS_INSTALLED=`fc-list | grep "$NERD_FONT_TITLE" | wc -l`
    ;;
*)
    print_error "Unsupported kernel: $KERNEL_NAME"
    exit 1
    ;;
esac

NERD_FONT_SOURCE_PATH="$NERD_FONT_SOURCE_DIR/$NERD_FONT_FILENAME"
NERD_FONT_INSTALL_PATH="$FONTS_INSTALL_DIR/$NERD_FONT_FILENAME"

if [[ $FONTS_INSTALLED -eq 0 ]]; then
    if [[ ! -d "$FONTS_INSTALL_DIR" ]]; then
        mkdir -p "$FONTS_INSTALL_DIR"
    fi
    cp -f "$NERD_FONT_SOURCE_PATH" "$NERD_FONT_INSTALL_PATH"
    print_information "Install font: $NERD_FONT_INSTALL_PATH"
else
    print_warning 'Fonts are already installed.'
fi

yes_or_no_question 'Update font cache?' INSTALL_VARIABLE_FONT_UPDATE_CACHE
if [[ $INSTALL_VARIABLE_FONT_UPDATE_CACHE -eq 1 ]]; then
    case $KERNEL_NAME in
    Linux)
        fc-cache -f -v
        ;;
    *)
        print_warning "Skip this process in this kernel($KERNEL_NAME)."
        ;;
    esac
fi

