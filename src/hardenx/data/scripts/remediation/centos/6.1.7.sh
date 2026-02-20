#!/bin/bash

set -euo pipefail

handle_failure() {
    echo "false"
    exit 1
}

trap handle_failure ERR

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ $# -ne 2 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

INTERVAL="$1"
COUNT_MAX="$2"
CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -w "$CONFIG_FILE" ]]; then
    exit 1
fi

if grep -qE "^\s*#?\s*ClientAliveInterval" "$CONFIG_FILE"; then
    sed -i -E "s/^\s*#?\s*ClientAliveInterval\s+.*/ClientAliveInterval $INTERVAL/" "$CONFIG_FILE"
else
    echo "ClientAliveInterval $INTERVAL" >> "$CONFIG_FILE"
fi

if grep -qE "^\s*#?\s*ClientAliveCountMax" "$CONFIG_FILE"; then
    sed -i -E "s/^\s*#?\s*ClientAliveCountMax\s+.*/ClientAliveCountMax $COUNT_MAX/" "$CONFIG_FILE"
else
    echo "ClientAliveCountMax $COUNT_MAX" >> "$CONFIG_FILE"
fi

sshd -t &>/dev/null

if systemctl is-active --quiet sshd; then
    systemctl reload sshd &>/dev/null
elif systemctl is-active --quiet ssh; then
    systemctl reload ssh &>/dev/null
else
    exit 1
fi

echo "true"