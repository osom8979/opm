#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPCODE=${1:-install}
FORCE=${FORCE:-0}
AUTOMATIC_YES=${AUTOMATIC_YES:-0}
VFI_FLAGS=${VFI_FLAGS:--v}

# https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
FONT_NAME="DroidSansMono Nerd Font"
FILE_NAME="Droid Sans Mono Nerd Font Complete.otf"

ALREADY_INSTALLED=0
KERNEL=$(uname -s)

case $KERNEL in
Darwin)
    INSTALL_DIR="$HOME/Library/Fonts"
    ;;
Linux)
    INSTALL_DIR="$HOME/.local/share/fonts"
    if command -v fc-list &> /dev/null; then
        ALREADY_INSTALLED=$(fc-list | grep -c "$FONT_NAME")
    else
        echo "Not found 'fc-list' command" 1>&2
        echo "It assumes it is not installed and runs" 1>&2
    fi
    ;;
*)
    echo "Unsupported kernel: $KERNEL" 1>&2
    exit 1
    ;;
esac

SRC=$OPM_HOME/etc/font/$FILE_NAME
DEST=$INSTALL_DIR/$FILE_NAME

function update_font_cache
{
    case $KERNEL in
    Linux)
        if ! command -v fc-cache &> /dev/null; then
            (
                echo "Not found 'fc-cache' command"
                echo "Please run the following command:"
                echo "  sudo apt install fontconfig"
            ) 1>&2
            exit 1
        fi
        fc-cache --force --verbose
        ;;
    *)
        echo "Font cache update for kernel '${KERNEL}' is not supported"
        ;;
    esac
}

function install
{
    if [[ $FORCE -eq 0 && $ALREADY_INSTALLED -gt 0 ]]; then
        echo "NERD Fonts are already installed" 1>&2
        exit 1
    fi

    if [[ ! -d "$INSTALL_DIR" ]]; then
        mkdir -vp "$INSTALL_DIR"
    fi

    cp "$VFI_FLAGS" "$SRC" "$DEST"
    echo "NERD font installation successful: $DEST"

    update_font_cache
}

function uninstall
{
    rm "$VFI_FLAGS" "$DEST"
}

if [[ $OPCODE == "install" ]]; then
    install
elif [[ $OPCODE == "uninstall" ]]; then
    uninstall
fi
