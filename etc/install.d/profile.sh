#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

OPCODE=${1:-install}
FORCE=${FORCE:-0}
AUTOMATIC_YES=${AUTOMATIC_YES:-0}
VFI_FLAGS=${VFI_FLAGS:--v}

CONTENT="
## OSOM PACKAGE MANAGER
export OPM_HOME=\"$OPM_HOME\"
if [[ -f \"\$OPM_HOME/profile.sh\" ]]; then
    source \"\$OPM_HOME/profile.sh\"
fi
"

function find_profile_path
{
    if [[ -n "$SHELL" ]]; then
        shell=${SHELL##*/}
    else
        shell=bash
    fi

    case $shell in
    bash)
        ## See INVOCATION in 'man bash'
        case $(uname -s) in
        Darwin)
            echo "$HOME/.profile"
            ;;
        *)
            echo "$HOME/.bashrc"
            ;;
        esac
        ;;
    zsh)
        echo "$HOME/.zshrc"
        ;;
    *)
        echo "$HOME/.profile"
        ;;
    esac
}

function install
{
    PROFILE=$(find_profile_path)

    if [[ $FORCE -eq 0 ]]; then
        if grep -q "^export OPM_HOME=" "$PROFILE"; then
            echo "The OPM_HOME variable is already declared in the '$PROFILE'" 1>&2
            exit 1
        fi
    fi

    {
        echo "## OSOM PACKAGE MANAGER"
        echo "export OPM_HOME=\"$OPM_HOME\""
        echo "if [[ -n \$OPM_HOME && -f \"\$OPM_HOME/profile.sh\" ]]; then"
        echo "    source \"\$OPM_HOME/profile.sh\""
        echo "fi"
    } >> "$PROFILE"
}

function uninstall
{
    PROFILE=$(find_profile_path)
    sed -i.back 's/^(export OPM_HOME=)/#\1/' "$PROFILE"
}

if [[ $OPCODE == "install" ]]; then
    install
elif [[ $OPCODE == "uninstall" ]]; then
    uninstall
fi
