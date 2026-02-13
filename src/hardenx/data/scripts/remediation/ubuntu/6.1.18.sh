#!/usr/bin/env bash

set -e
trap 'echo "false"' ERR

if [[ $EUID -ne 0 ]]; then
   exit 1
fi

if [[ $# -ne 1 ]]; then
   exit 1
fi

MAX_STARTUPS_VALUE="$1"
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG_FILE" ] || [ ! -w "$SSHD_CONFIG_FILE" ]; then
    exit 1
fi

# Create a backup before modifying
cp "$SSHD_CONFIG_FILE" "${SSHD_CONFIG_FILE}.bak.$(date +%s)"

# Use sed to find and replace the line, or awk to append if not found.
# This avoids two separate file reads.
if grep -qE "^\s*#?\s*MaxStartups\s+" "$SSHD_CONFIG_FILE"; then
    sed -i -E "s/^\s*#?\s*MaxStartups\s+.*/MaxStartups ${MAX_STARTUPS_VALUE}/" "$SSHD_CONFIG_FILE"
else
    echo "" >> "$SSHD_CONFIG_FILE"
    echo "MaxStartups ${MAX_STARTUPS_VALUE}" >> "$SSHD_CONFIG_FILE"
fi

# Restart the SSH service using the most appropriate command
if command -v systemctl &>/dev/null && systemctl is-active --quiet sshd &>/dev/null; then
    systemctl restart sshd
elif command -v systemctl &>/dev/null && systemctl is-active --quiet ssh &>/dev/null; then
    systemctl restart ssh
elif command -v service &>/dev/null; then
    service sshd restart 2>/dev/null || service ssh restart
else
    # Fallback for systems without systemctl or service, or if service fails
    if [ -f /etc/init.d/sshd ]; then
        /etc/init.d/sshd restart
    elif [ -f /etc/init.d/ssh ]; then
        /etc/init.d/ssh restart
    else
        exit 1
    fi
fi

echo "true"