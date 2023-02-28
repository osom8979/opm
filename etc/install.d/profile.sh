#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

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

PROFILE=$(find_profile_path)

if grep -q "^export OPM_HOME=" "$PROFILE"; then
    echo "The OPM_HOME variable is already declared in the '$PROFILE'" 1>&2
    exit 1
fi

echo "$CONTENT" >> "$PROFILE"
