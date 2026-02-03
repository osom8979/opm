#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPCODE=${1:-install}
FORCE=${FORCE:-0}
AUTOMATIC_YES=${AUTOMATIC_YES:-0}
IFS=" " read -r -a VFI_FLAGS <<< "${VFI_FLAGS:--v}"

# https://raw.githubusercontent.com/alacritty/alacritty/master/alacritty.yml
YAML_SRC=$OPM_HOME/etc/alacritty/alacritty.yml
YAML_DEST=$HOME/.alacritty.yml

TOML_SRC=$OPM_HOME/etc/alacritty/alacritty.toml
TOML_DEST=$HOME/.alacritty.toml

function install
{
    if [[ $FORCE -eq 0 && ! -f "$YAML_SRC" ]]; then
        echo "Not found source file: '$YAML_SRC'" 1>&2
        exit 1
    fi
    if [[ $FORCE -eq 0 && ! -f "$TOML_SRC" ]]; then
        echo "Not found source file: '$TOML_SRC'" 1>&2
        exit 1
    fi

    if [[ $FORCE -eq 0 && -e "$YAML_DEST" ]]; then
        echo "The alacritty configuration file already exists" 1>&2
        echo "Delete the file to continue installation" 1>&2
        echo " $YAML_DEST" 1>&2
        exit 1
    fi
    if [[ $FORCE -eq 0 && -e "$TOML_DEST" ]]; then
        echo "The alacritty configuration file already exists" 1>&2
        echo "Delete the file to continue installation" 1>&2
        echo " $TOML_DEST" 1>&2
        exit 1
    fi

    {
        echo "## OSOM PACKAGE MANAGER"
        echo "import:"
        echo "  - $YAML_SRC"
    } >> "$YAML_DEST"
    echo "alacritty installation successful: $YAML_DEST"

    {
        echo "[general]"
        echo "import = [\"$TOML_SRC\"]"
    } >> "$TOML_DEST"
    echo "alacritty installation successful: $TOML_DEST"
}

function uninstall
{
    rm "${VFI_FLAGS[@]}" "$YAML_DEST"
    rm "${VFI_FLAGS[@]}" "$TOML_DEST"
}

if [[ $OPCODE == "install" ]]; then
    install
elif [[ $OPCODE == "uninstall" ]]; then
    uninstall
fi
