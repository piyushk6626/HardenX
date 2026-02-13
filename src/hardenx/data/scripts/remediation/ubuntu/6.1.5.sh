#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

BANNER_FILE="$1"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -f "$BANNER_FILE" ]]; then
    echo "false"
    exit 1
fi

# Backup the original config file
cp "$SSH_CONFIG_FILE" "${SSH_CONFIG_FILE}.bak-$(date +%s)"

# Escape the file path for sed to handle slashes and other special characters
ESCAPED_BANNER_FILE=$(sed 's/[&/\]/\\&/g' <<<"$BANNER_FILE")

# Check if the Banner directive exists (commented or not) and update it
if grep -qE '^[[:space:]]*#?[[:space:]]*Banner' "$SSH_CONFIG_FILE"; then
    sed -i "s/^[[:space:]]*#?[[:space:]]*Banner.*/Banner ${ESCAPED_BANNER_FILE}/" "$SSH_CONFIG_FILE"
else
    # If it doesn't exist, add it to the end of the file
    echo "" >> "$SSH_CONFIG_FILE"
    echo "Banner ${BANNER_FILE}" >> "$SSH_CONFIG_FILE"
fi

# Attempt to restart the SSH service
if systemctl restart sshd &>/dev/null || systemctl restart ssh &>/dev/null; then
    echo "true"
    exit 0
else
    # If restart fails, revert the change
    mv "${SSH_CONFIG_FILE}.bak" "$SSH_CONFIG_FILE" &>/dev/null
    echo "false"
    exit 1
fi