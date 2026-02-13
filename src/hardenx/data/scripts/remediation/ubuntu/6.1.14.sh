#!/usr/bin/env bash

if [[ $EUID -ne 0 || $# -ne 1 ]]; then
   echo "false"
   exit 1
fi

LOG_LEVEL="$1"
CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -f "$CONFIG_FILE" || ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Create a backup just in case
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Check if LogLevel line exists (commented or not) and replace/append
if grep -qE '^[[:space:]]*#?[[:space:]]*LogLevel' "$CONFIG_FILE"; then
    sed -i "s/^[[:space:]]*#?[[:space:]]*LogLevel.*/LogLevel $LOG_LEVEL/" "$CONFIG_FILE"
else
    echo "LogLevel $LOG_LEVEL" >> "$CONFIG_FILE"
fi

# Check if the previous command succeeded
if [[ $? -ne 0 ]]; then
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi

# Restart sshd service, trying common names
if systemctl restart sshd >/dev/null 2>&1 || systemctl restart ssh >/dev/null 2>&1; then
    rm -f "${CONFIG_FILE}.bak"
    echo "true"
else
    # Restore from backup if restart fails
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi