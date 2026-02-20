#!/usr/bin/env bash

set -eo pipefail

if [[ $# -ne 1 ]] || [[ "$1" != "yes" && "$1" != "no" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
NEW_VALUE="$1"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Use a trap to output 'false' on any error
trap 'echo "false"' ERR

# Check if the setting exists (commented or uncommented) and update it
if grep -qE '^[[:space:]]*#?[[:space:]]*IgnoreRhosts' "$CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*IgnoreRhosts.*/IgnoreRhosts ${NEW_VALUE}/" "$CONFIG_FILE"
# If it does not exist, append it to the end of the file
else
    echo "IgnoreRhosts ${NEW_VALUE}" >> "$CONFIG_FILE"
fi

# Reload sshd service to apply changes
if command -v systemctl &> /dev/null && systemctl is-enabled --quiet sshd &> /dev/null; then
    systemctl reload sshd
elif command -v systemctl &> /dev/null && systemctl is-enabled --quiet ssh &> /dev/null; then
    systemctl reload ssh
elif command -v service &> /dev/null; then
    service sshd reload || service ssh reload
else
    # No known service manager found to reload the service
    exit 1
fi

echo "true"
exit 0