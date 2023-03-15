#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

IPTABLES_CMD=$(command -v iptables 2> /dev/null)
IPTABLES_SAVE_CMD=$(command -v iptables-save 2> /dev/null)
IPTABLES_RESTORE_CMD=$(command -v iptables-restore 2> /dev/null)

if [[ -z "$IPTABLES_CMD" ]]; then
    IPTABLES_CMD="/sbin/iptables"
    if [[ ! -x "$IPTABLES_CMD" ]]; then
        echo "Not found iptables command" 1>&2
        exit 1
    fi
fi

if [[ -z "$IPTABLES_SAVE_CMD" ]]; then
    IPTABLES_SAVE_CMD="/sbin/iptables-save"
    if [[ ! -x "$IPTABLES_SAVE_CMD" ]]; then
        echo "Not found iptables-save command" 1>&2
        exit 1
    fi
fi

if [[ -z "$IPTABLES_RESTORE_CMD" ]]; then
    IPTABLES_RESTORE_CMD="/sbin/iptables-restore"
    if [[ ! -x "$IPTABLES_RESTORE_CMD" ]]; then
        echo "Not found iptables-restore command" 1>&2
        exit 1
    fi
fi

if ! command opm-home &> /dev/null; then
PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../bin" || exit; pwd):$PATH"
fi

if ! command opm-home &> /dev/null; then
    echo "Not found opm-home command" 1>&2
    exit 1
fi

NOW=$(date "+%Y%m%d_%H%M%S")
BACKUP_DIR=$(opm-home)/var/iptables/backups

if [[ -d "$BACKUP_DIR" ]]; then
    mkdir -vp "$BACKUP_DIR"
fi

BACKUP_FILE="$BACKUP_DIR/iptables-$NOW.rules"
BACKUP_FILE_LATEST="$BACKUP_DIR/latest"

if ! "$IPTABLES_SAVE_CMD" > "$BACKUP_FILE"; then
    echo "iptables backup failed" 1>&2
    exit 1
fi

if ! ln -s "$BACKUP_FILE" "$BACKUP_FILE_LATEST"; then
    echo "Failed to create latest symlink" 1>&2
    exit 1
fi

IPTABLES_SERVER_FILTER="# Set a default policy of DROP
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]

# Accept any related or established connections
-I INPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
-I OUTPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow all traffic on the loopback interface
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT

# Allow outbound DHCP request
-A OUTPUT –o eth0 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# Allow inbound SSH
-A INPUT -i eth0 -p tcp -m tcp --dport 22 -m state --state NEW  -j ACCEPT

# Allow outbound email
-A OUTPUT -i eth0 -p tcp -m tcp --dport 25 -m state --state NEW  -j ACCEPT

# Outbound DNS lookups
-A OUTPUT -o eth0 -p udp -m udp --dport 53 -j ACCEPT

# Outbound PING requests
-A OUTPUT –o eth0 -p icmp -j ACCEPT

# Outbound Network Time Protocol (NTP) requests
-A OUTPUT –o eth0 -p udp --dport 123 --sport 123 -j ACCEPT

# Outbound HTTP
-A OUTPUT -o eth0 -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m tcp --dport 443 -m state --state NEW -j ACCEPT

COMMIT
"

read -r -p "Do you really apply filters? (y/n) " ANSWER
if [[ ${ANSWER,,} != 'y' ]]; then
    echo "Job canceled" 1>&2
    exit 1
fi

if ! echo "$IPTABLES_SERVER_FILTER" | "$IPTABLES_RESTORE_CMD"; then
    echo "Filter application failed" 1>&2
    exit 1
fi

"$IPTABLES_CMD" -L
