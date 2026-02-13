#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"
CONFIG_FILE="/etc/ssh/sshd_config"
DIRECTIVE="DisableForwarding"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Create a backup just in case
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak" || { echo "false"; exit 1; }

# Check if the directive exists (commented or uncommented)
if grep -qE "^[[:space:]]*#?[[:space:]]*${DIRECTIVE}" "$CONFIG_FILE"; then
    # If it exists, replace it using sed. Handles both commented and uncommented cases.
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*${DIRECTIVE}.*/${DIRECTIVE} ${DESIRED_STATE}/" "$CONFIG_FILE"
else
    # If it does not exist, append it to the end of the file.
    echo "" >> "$CONFIG_FILE"
    echo "${DIRECTIVE} ${DESIRED_STATE}" >> "$CONFIG_FILE"
fi

# Verify the change was made successfully
if ! grep -qE "^[[:space:]]*${DIRECTIVE}[[:space:]]+${DESIRED_STATE}" "$CONFIG_FILE"; then
    # If change failed, restore from backup and exit
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi

# Reload the sshd service. Prioritize systemctl.
if command -v systemctl &>/dev/null && systemctl is-active --quiet sshd; then
    systemctl reload sshd
elif command -v service &>/dev/null; then
    service sshd reload
else
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi

if [[ $? -eq 0 ]]; then
    rm -f "${CONFIG_FILE}.bak"
    echo "true"
else
    # If reload fails, restore the original config
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
fi