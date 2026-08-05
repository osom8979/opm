#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

SSHD_CONFIG_PATH=/etc/ssh/sshd_config
SSHD_CONFIG_DIR=/etc/ssh/sshd_config.d
BACKUP_PATH="$SSHD_CONFIG_PATH.$(date '+%Y%m%d_%H%M%S').bak"

if [[ ! -f "$SSHD_CONFIG_PATH" ]]; then
    echo "Not found sshd_config file: '$SSHD_CONFIG_PATH'" 1>&2
    echo "Please run the '004-ssh-server.sh' script first" 1>&2
    exit 1
fi

## Prevent lockout: at least one non-empty authorized_keys must exist.
AUTHORIZED_KEYS_EXISTS=0
for HOME_DIR in /root /home/*; do
    AUTHORIZED_KEYS_PATH="$HOME_DIR/.ssh/authorized_keys"
    if [[ -s "$AUTHORIZED_KEYS_PATH" ]]; then
        echo "Found authorized_keys: '$AUTHORIZED_KEYS_PATH'"
        AUTHORIZED_KEYS_EXISTS=1
    fi
done

if [[ $AUTHORIZED_KEYS_EXISTS -eq 0 ]]; then
    echo "Not found any non-empty authorized_keys file" 1>&2
    echo "Disabling password authentication now can lock you out" 1>&2

    read -r -p "Do you want to continue anyway? (y/N) " FORCE_ANSWER
    if [[ ! "$FORCE_ANSWER" =~ ^[yY]$ ]]; then
        exit 1
    fi
fi

cp --verbose "$SSHD_CONFIG_PATH" "$BACKUP_PATH"

function update_sshd_config
{
    local key=$1
    local value=$2

    if grep -q -E "^[[:space:]]*#?[[:space:]]*${key}[[:space:]]+" "$SSHD_CONFIG_PATH"; then
        sed --in-place -E \
            "s|^[[:space:]]*#?[[:space:]]*($key)[[:space:]]+.*$|\1 $value|" \
            "$SSHD_CONFIG_PATH"
    else
        echo "$key $value" >> "$SSHD_CONFIG_PATH"
    fi

    if grep -q -E "^$key +$value$" "$SSHD_CONFIG_PATH"; then
        echo "Applied '$key $value'"
    else
        echo "Failed to apply '$key $value'" 1>&2
        echo "Please edit yourself: '$SSHD_CONFIG_PATH'" 1>&2
        exit 1
    fi
}

## Allow public key authentication only.
update_sshd_config PubkeyAuthentication yes
update_sshd_config PasswordAuthentication no
update_sshd_config KbdInteractiveAuthentication no
update_sshd_config ChallengeResponseAuthentication no
update_sshd_config PermitEmptyPasswords no
update_sshd_config PermitRootLogin prohibit-password
update_sshd_config AuthenticationMethods publickey

## Drop-in files are included at the top of sshd_config and win over it.
## Comment out the conflicting keywords so the settings above take effect.
CONFLICT_KEYS='PubkeyAuthentication|PasswordAuthentication|KbdInteractiveAuthentication|ChallengeResponseAuthentication|PermitEmptyPasswords|PermitRootLogin|AuthenticationMethods'

if grep -q -E "^[[:space:]]*Include[[:space:]]+$SSHD_CONFIG_DIR/" "$SSHD_CONFIG_PATH"; then
    shopt -s nullglob
    for DROP_IN_PATH in "$SSHD_CONFIG_DIR"/*.conf; do
        if ! grep -q -E "^[[:space:]]*($CONFLICT_KEYS)[[:space:]]+" "$DROP_IN_PATH"; then
            continue
        fi

        echo "Found conflicting settings in drop-in file: '$DROP_IN_PATH'" 1>&2
        grep -n -E "^[[:space:]]*($CONFLICT_KEYS)[[:space:]]+" "$DROP_IN_PATH" 1>&2

        read -r -p "Do you want to comment them out? (y/N) " DROP_IN_ANSWER
        if [[ "$DROP_IN_ANSWER" =~ ^[yY]$ ]]; then
            cp --verbose "$DROP_IN_PATH" "$DROP_IN_PATH.$(date '+%Y%m%d_%H%M%S').bak"
            sed --in-place -E \
                "s%^([[:space:]]*($CONFLICT_KEYS)[[:space:]]+.*)$%#\1%" \
                "$DROP_IN_PATH"
            echo "Commented out the conflicting settings: '$DROP_IN_PATH'"
        else
            echo "Skipped: '$DROP_IN_PATH'" 1>&2
            echo "The settings in '$SSHD_CONFIG_PATH' may be ignored" 1>&2
        fi
    done
    shopt -u nullglob
fi

## Validate before restarting, otherwise sshd fails to start.
if ! sshd -t; then
    echo "Invalid sshd configuration" 1>&2
    cp --verbose "$BACKUP_PATH" "$SSHD_CONFIG_PATH"
    echo "Restored the backup file: '$BACKUP_PATH'" 1>&2
    exit 1
fi

echo "The sshd configuration is valid"
echo "Backup file: '$BACKUP_PATH'"

if ! command -v systemctl &> /dev/null; then
    echo "Not found systemctl command" 1>&2
    echo "Please reload the ssh service yourself" 1>&2
    exit 0
fi

read -r -p "Reload the ssh service now? (y/N) " RELOAD_ANSWER
if [[ "$RELOAD_ANSWER" =~ ^[yY]$ ]]; then
    ## Reload keeps the established sessions alive.
    systemctl reload ssh
    systemctl --no-pager status ssh
else
    echo "Please reload the ssh service yourself: 'systemctl reload ssh'"
fi
