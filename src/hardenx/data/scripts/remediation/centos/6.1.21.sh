#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ $# -ne 1 ]] || [[ "$1" != "yes" && "$1" != "no" ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
CONFIG_FILE="/etc/ssh/sshd_config"
DIRECTIVE="PermitUserEnvironment"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Create a backup before modifying
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# If the directive exists (commented or not), replace it. Otherwise, add it.
if grep -qE "^\s*#?\s*${DIRECTIVE}" "$CONFIG_FILE"; then
    sed -i "s/^\s*#?\s*${DIRECTIVE}.*/${DIRECTIVE} ${VALUE}/" "$CONFIG_FILE"
else
    echo "" >> "$CONFIG_FILE"
    echo "${DIRECTIVE} ${VALUE}" >> "$CONFIG_FILE"
fi

# Verify the change was successful
if ! grep -qE "^\s*${DIRECTIVE}\s+${VALUE}" "$CONFIG_FILE"; then
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi

# Restart the SSH service
restarted=false
if command -v systemctl &>/dev/null; then
    if systemctl restart sshd.service &>/dev/null || systemctl restart ssh.service &>/dev/null; then
        restarted=true
    fi
elif command -v service &>/dev/null; then
    if service sshd restart &>/dev/null || service ssh restart &>/dev/null; then
        restarted=true
    fi
fi

if [[ "$restarted" == "true" ]]; then
    rm -f "${CONFIG_FILE}.bak"
    echo "true"
else
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi