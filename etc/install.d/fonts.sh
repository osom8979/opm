#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"
NERD_FONTS_NAME="Droid Sans Mono for Powerline Nerd Font Complete.otf"

case "$(uname -s)" in
Darwin)
    curl -fLo "~/Library/Fonts/$NERD_FONTS_NAME" "$NERD_FONTS_URL"
    ;;
Linux)
    mkdir -p ~/.local/share/fonts
    curl -fLo "~/.local/share/fonts/$NERD_FONTS_NAME" "$NERD_FONTS_URL"
    ;;
CYGWIN*|MINGW*|MSYS*)
    exit 1
    ;;
*)
    exit 1
    ;;
esac

