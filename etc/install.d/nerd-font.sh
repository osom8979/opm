#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

# https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
FONT_NAME="DroidSansMono Nerd Font"
FILE_NAME="Droid Sans Mono Nerd Font Complete.otf"

KERNEL=$(uname -s)

case $KERNEL in
Darwin)
    INSTALL_DIR="$HOME/Library/Fonts"
    INSTALLED=0
    ;;
Linux)
    INSTALL_DIR="$HOME/.local/share/fonts"
    if command -v fc-list &> /dev/null; then
        INSTALLED=$(fc-list | grep -c "$FONT_NAME")
    else
        echo "Not found 'fc-list' command" 1>&2
        echo "It assumes it is not installed and runs" 1>&2
        INSTALLED=0
    fi
    ;;
*)
    echo "Unsupported kernel: $KERNEL" 1>&2
    exit 1
    ;;
esac

if [[ $INSTALLED -gt 0 ]]; then
    echo "NERD Fonts are already installed" 1>&2
    exit 1
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -vp "$INSTALL_DIR"
fi

SRC="$OPM_HOME/etc/font/$FILE_NAME"
DEST="$INSTALL_DIR/$FILE_NAME"

if [[ -f "$DEST" ]]; then
    cp -v "$SRC" "$DEST"
    echo "NERD font installation successful: $DEST"
else
    echo "NERD font file already exists: $DEST"
fi

case $KERNEL in
Linux)
    if ! command -v fc-cache &> /dev/null; then
        echo "Not found 'fc-cache' command" 1>&2
        exit 1
    fi
    fc-cache --force --verbose
    ;;
*)
    echo "Font cache update for kernel '${KERNEL}' is not supported"
    ;;
esac
