#!/usr/bin/env bash

if [[ "$#" -ne 1 ]] || [[ "$1" != "yes" && "$1" != "no" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
DIRECTIVE="IgnoreRhosts"
VALUE="$1"

if [[ ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Modify the configuration file
if grep -q -E "^[#\s]*${DIRECTIVE}\s+" "$CONFIG_FILE"; then
    # Directive exists (commented or not), so we replace the line
    sed -i "s/^[#\s]*${DIRECTIVE}\s+.*/${DIRECTIVE} ${VALUE}/" "$CONFIG_FILE"
    MOD_STATUS=$?
else
    # Directive does not exist, so we append it
    echo "${DIRECTIVE} ${VALUE}" >> "$CONFIG_FILE"
    MOD_STATUS=$?
fi

if [[ "$MOD_STATUS" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Restart the sshd service to apply changes
if systemctl restart sshd &>/dev/null; then
    echo "true"
else
    echo "false"
fi