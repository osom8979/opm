#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
INSTALL_DIR=$SCRIPT_DIR/etc/install.d
VIA_INSTALLATION_SCRIPT=1

INSTALL_VARIABLES_PATH=$SCRIPT_DIR/variables
LIST_OF_COMPONENTS=0
INSTALL_VARIABLES_FLAG=0
AUTOMATIC_YES_FLAG=0
DRY_RUN=0
FORCE_FLAG=0

function print_message
{
    echo "$@"
}

function print_information
{
    echo -e "\033[32m$@\033[0m"
}

function print_warning
{
    echo -e "\033[33m$@\033[0m"
}

function print_error
{
    echo -e "\033[31m$@\033[0m" 1>&2
}

function print_usage
{
    print_message "Usage: $0 [options] [com1] [com2] ... [comN]"
    print_message ""
    print_message "Available options are:"
    print_message "  -h, --help     Print this message."
    print_message "  -c, --create-install-variables-file"
    print_message "                 Generated environment variable file for installation."
    print_message "  -l, --list     List of components."
    print_message "  -y, --yes      Automatic yes to prompts."
    print_message "  -n, --dry-run  Don't actually do anything, just show what would be done."
    print_message "  -f, --force    Skip checking the OPM_HOME variable."
    print_message "  --             Skip handling options."
}

COMPONENTS=
while [[ ! -z $1 ]]; do
    case $1 in
    -h|--help)
        print_usage
        exit 0
        ;;
    -c|--create-install-variables-file)
        INSTALL_VARIABLES_FLAG=1
        shift
        ;;
    -l|--list)
        LIST_OF_COMPONENTS=1
        shift
        ;;
    -y|--yes)
        AUTOMATIC_YES_FLAG=1
        shift
        ;;
    -n|--dry-run)
        DRY_RUN=1
        shift
        ;;
    -f|--force)
        FORCE_FLAG=1
        shift
        ;;
    --)
        shift
        break
        ;;
    -*|--*)
        print_error "Unknown option: $1"
        exit 1
        ;;
    *)
        COMPONENTS="$COMPONENTS $INSTALL_DIR/$1.sh"
        shift
        ;;
    esac
done

if [[ $LIST_OF_COMPONENTS -eq 1 ]]; then
    __component_names=
    for cursor in $INSTALL_DIR/*.sh; do
        __current_component_names=`echo "$cursor" | sed -E 's/.*\/([^\/]+)\.sh$/\1/g'`
        __component_names="$__component_names $__current_component_names"
    done
    print_message $__component_names
    exit 0
fi

if [[ $INSTALL_VARIABLES_FLAG -eq 1 ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
        # Comment out the original content.
        if [[ -f "$INSTALL_VARIABLES_PATH" ]]; then
            sed -e 's/^/#/g' "$INSTALL_VARIABLES_PATH" > "$INSTALL_VARIABLES_PATH"
        fi
        # Extract environment variables for installation.
        for cursor in $INSTALL_DIR/*.sh; do
            grep -E '^INSTALL_VARIABLE_.*' "$cursor" | sed -e 's/=.*/=/g' >> "$INSTALL_VARIABLES_PATH"
        done
    fi
    print_information "Generated environment variable file for installation: $INSTALL_VARIABLES_PATH"
    exit 0
fi

if [[ -f "$INSTALL_VARIABLES_PATH" ]]; then
    source "$INSTALL_VARIABLES_PATH"
fi

if [[ -z $BASH_PROFILE_PATH ]]; then
    ## See INVOCATION in 'man bash'
    if [[ $(uname -s) == "Darwin" ]]; then
        BASH_PROFILE_PATH="$HOME/.profile"
    else
        BASH_PROFILE_PATH="$HOME/.bashrc"
    fi
fi

if [[ ! -z "$OPM_HOME" || ! -z $(cat "$BASH_PROFILE_PATH" | grep "OPM_HOME") ]]; then
    print_warning 'OPM_HOME variable is already the declared.'
    if [[ $FORCE_FLAG -ne 1 ]]; then
        exit 1
    fi
else
    if [[ $DRY_RUN -eq 0 ]]; then
        echo ''                                         >> $BASH_PROFILE_PATH
        echo '## OSOM Common Script.'                   >> $BASH_PROFILE_PATH
        echo "export OPM_HOME=$SCRIPT_DIR"              >> $BASH_PROFILE_PATH
        echo 'if [[ -f "$OPM_HOME/profile.sh" ]]; then' >> $BASH_PROFILE_PATH
        echo '    . "$OPM_HOME/profile.sh"'             >> $BASH_PROFILE_PATH
        echo 'fi'                                       >> $BASH_PROFILE_PATH
    fi
    print_information "Update $BASH_PROFILE_PATH file."
fi

if [[ -z "$OPM_HOME" ]]; then
OPM_HOME=$SCRIPT_DIR
fi

## -----------------
## Install software.
## -----------------

function backup_file
{
    local source_file=$1
    local backup_prev=0
    local read_answer=n
    local date_format=`date +%Y%m%d_%H%M%S`
    local backup_suffix=$date_format.backup
    local backup_path="$source_file.$backup_suffix"

    if [[ -f $source_file ]]; then
        if [[ $AUTOMATIC_YES_FLAG -eq 1 ]]; then
            backup_prev=1
        else
            read -p "Backup the previous ${source_file}? (y/n) " read_answer
            case "$read_answer" in
            [yY]*)
                backup_prev=1
                ;;
            *)
                backup_prev=0
                ;;
            esac
        fi
        if [[ $backup_prev -eq 1 ]]; then
            cp -f "$source_file" "$backup_path"
            print_message "Backup complete: $backup_path"
        fi
    fi
}

function yes_or_no_question
{
    local read_prompt=$1
    local read_answer=n
    local result_variable=$2

    if [[ $AUTOMATIC_YES_FLAG -eq 0 ]]; then
        if [[ -z ${!result_variable} ]]; then
            read -p "$read_prompt (y/n) " read_answer
            case "$read_answer" in
            [yY]*)
                eval "$result_variable=1"
                ;;
            *)
                eval "$result_variable=0"
                ;;
            esac
        fi
    fi
}

function symbolic_link
{
    local source_file=$1
    local link_file=$2

    if [[ -f "$link_file" ]]; then
        rm "$link_file"
    fi

    ln -s "$source_file" "$link_file"
    print_information "Symbolic link: $link_file"
}

function mkdirs
{
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi
}

function remove_file
{
    if [[ -f "$1" ]]; then
        rm "$1"
    fi
}

function copy_file
{
    local src=$1
    local dest=$2

    cp "$src" "$dest"
}

## Warning: Don't use the quoting("...").
if [[ -z $COMPONENTS ]]; then
COMPONENTS=$INSTALL_DIR/*.sh
fi

com_index=1
com_size=0
for cursor in $COMPONENTS; do
    ((com_size++))
done

for cursor in $COMPONENTS; do
    if [[ ! -f $cursor ]]; then
        print_error "[$com_index/$com_size] Not found component: $cursor"
        exit 1
    fi

    print_information "[$com_index/$com_size] Install component: $cursor"
    if [[ $DRY_RUN -eq 0 ]]; then
        source $cursor
    else
        echo "source $cursor"
    fi

    if [[ $? -ne 0 ]]; then
        print_error "[$com_index/$com_size] Install failure(code=$?): $cursor"
        exit 1
    fi
    echo ''
    ((com_index++))
done

print_information 'Done.'

