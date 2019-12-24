#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

NERD_FONTS_SOURCE_DIR="$OPM_HOME/etc/font"
NERD_FONTS_NAME="Droid Sans Mono Nerd Font Complete.otf"
NERD_FONTS_SOURCE_PATH="$NERD_FONTS_SOURCE_DIR/$NERD_FONTS_NAME"
NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"

case "$(uname -s)" in
Darwin)
    FONTS_INSTALL_DIR="$HOME/Library/Fonts"
    ;;
Linux)
    FONTS_INSTALL_DIR="$HOME/.local/share/fonts"
    ;;
CYGWIN*|MINGW*|MSYS*)
    exit 1
    ;;
*)
    exit 1
    ;;
esac

if [[ ! -d "$FONTS_INSTALL_DIR" ]]; then
    mkdir -p "$FONTS_INSTALL_DIR"
fi

cp "$NERD_FONTS_SOURCE_PATH" "$FONTS_INSTALL_DIR"

if [[ "$(uname -s)" == Linux ]]; then
    fc-cache -f -v
fi

