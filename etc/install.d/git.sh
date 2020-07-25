#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    print_error 'Not defined OPM_HOME variable.'
    exit 1
fi
if [[ $VIA_INSTALLATION_SCRIPT -ne 1 ]]; then
    print_error 'You have to do it through the installation script.'
    exit 1
fi

AUTOMATIC_YES_FLAG=${AUTOMATIC_YES_FLAG:-0}
INSTALL_VARIABLE_GIT_USER_NAME=$INSTALL_VARIABLE_GIT_USER_NAME
INSTALL_VARIABLE_GIT_USER_EMAIL=$INSTALL_VARIABLE_GIT_USER_EMAIL
INSTALL_VARIABLE_GIT_STORE_CREDENTIAL=$INSTALL_VARIABLE_GIT_STORE_CREDENTIAL

GITCONFIG=$HOME/.gitconfig
SRC_GITCONFIG=$OPM_HOME/etc/git/gitconfig

## Backup the previous gitconfig file.
backup_file "$GITCONFIG"

## Remove the previous gitconfig file.
rm -f "$GITCONFIG"

## Install [include] section.
echo -e "[include]"               >> $GITCONFIG
echo -e "\tpath = $SRC_GITCONFIG" >> $GITCONFIG
print_information "Write [include] section."

## Install [user] section.
if [[ $AUTOMATIC_YES_FLAG -eq 0 ]]; then
    if [[ -z $INSTALL_VARIABLE_GIT_USER_NAME ]]; then
        read -p "User name? " INSTALL_VARIABLE_GIT_USER_NAME
    fi
    if [[ -z $INSTALL_VARIABLE_GIT_USER_EMAIL ]]; then
        read -p "User email? " INSTALL_VARIABLE_GIT_USER_EMAIL
    fi
fi
if [[ ! -z $INSTALL_VARIABLE_GIT_USER_NAME || ! -z $INSTALL_VARIABLE_GIT_USER_EMAIL ]]; then
    echo -e "[user]"                                     >> $GITCONFIG
    echo -e "\tname = $INSTALL_VARIABLE_GIT_USER_NAME"   >> $GITCONFIG
    echo -e "\temail = $INSTALL_VARIABLE_GIT_USER_EMAIL" >> $GITCONFIG
    print_information "Write [user] section."
else
    print_warning "Skip [user] section."
fi

## Install [credential] section.
yes_or_no_question "Set Credential helper to 'store'?" INSTALL_VARIABLE_GIT_STORE_CREDENTIAL
if [[ $INSTALL_VARIABLE_GIT_STORE_CREDENTIAL -eq 1 ]]; then
    echo -e "[credential]"     >> $GITCONFIG
    echo -e "\thelper = store" >> $GITCONFIG
    print_information "Write [credential] section."
else
    print_warning "Skip [credential] section."
fi

print_information "Check installed file: $GITCONFIG"

