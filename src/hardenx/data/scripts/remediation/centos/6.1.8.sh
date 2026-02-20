#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$1" != "yes" ]] || [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
SETTING="DisableForwarding"
VALUE="$1"

# Ensure the config file exists and is writable
if [[ ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# If the setting exists (commented or not), modify it.
if grep -qE "^#?\s*${SETTING}" "$CONFIG_FILE"; then
    sed -i.bak -E "s/^#?\s*${SETTING}.*/${SETTING} ${VALUE}/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
# If the setting does not exist, add it to the end of the file.
else
    echo "${SETTING} ${VALUE}" >> "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

rm -f "${CONFIG_FILE}.bak"

# Reload the sshd service to apply changes
if command -v systemctl &>/dev/null && systemctl is-active --quiet sshd; then
    systemctl reload sshd
elif command -v service &>/dev/null; then
    service sshd reload
else
    echo "false"
    exit 1
fi

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi