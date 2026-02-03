#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v alacritty &> /dev/null; then
    echo "Not found alacritty command" 1>&2
    exit 1
fi

ALACRITTY_EXE="/usr/local/bin/alacritty"
ALACRITTY_SVG="/usr/share/pixmaps/Alacritty.svg"

if [[ ! -x "$ALACRITTY_EXE" ]]; then
    cp -v "$(which alacritty)" "$ALACRITTY_EXE"
fi

if [[ ! -f "$ALACRITTY_SVG" ]]; then
    cp -v "$CURRENT_DIR/alacritty-term.svg" "$ALACRITTY_SVG"
fi

desktop-file-install "$CURRENT_DIR/Alacritty.desktop"
update-desktop-database
