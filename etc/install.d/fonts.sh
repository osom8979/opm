#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

NERD_FONTS_NAME="Droid Sans Mono Nerd Font Complete.otf"
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

cp "$OPM_HOME/etc/font/Droid Sans Mono Nerd Font Complete.otf" "$FONTS_INSTALL_DIR"

