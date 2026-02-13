#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   exit 1
fi

CIPHERS="$1"
CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 1
fi

# Create a backup before modification
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak_$(date +%s)"
if [[ $? -ne 0 ]]; then
    exit 1
fi

# If a Ciphers line (commented or uncommented) exists, replace it.
if grep -qE '^[#\s]*Ciphers ' "$CONFIG_FILE"; then
    sed -i "s/^[#\s]*Ciphers .*/Ciphers ${CIPHERS}/" "$CONFIG_FILE"
# Otherwise, add the new Ciphers line to the end of the file.
else
    echo "" >> "$CONFIG_FILE"
    echo "Ciphers ${CIPHERS}" >> "$CONFIG_FILE"
fi

# Verify the change and return success or failure
if grep -qFx "Ciphers ${CIPHERS}" "$CONFIG_FILE"; then
    exit 0
else
    exit 1
fi