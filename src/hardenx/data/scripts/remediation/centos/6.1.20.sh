#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
NEW_VALUE="$1"

if [[ ! -w "$SSHD_CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Use a temporary file to avoid corrupting the original on error
TMP_FILE=$(mktemp)
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi
trap 'rm -f "$TMP_FILE"' EXIT

if grep -qE '^\s*#?\s*PermitRootLogin' "$SSHD_CONFIG_FILE"; then
    sed -E "s/^\s*#?\s*PermitRootLogin.*/PermitRootLogin $NEW_VALUE/" "$SSHD_CONFIG_FILE" > "$TMP_FILE"
else
    cp "$SSHD_CONFIG_FILE" "$TMP_FILE"
    echo "PermitRootLogin $NEW_VALUE" >> "$TMP_FILE"
fi

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Verify syntax before moving the file into place
sshd -t -f "$TMP_FILE" &>/dev/null
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Atomic move to replace the config file
mv "$TMP_FILE" "$SSHD_CONFIG_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi
# Disarm trap since the temp file has been moved
trap - EXIT

# Restart SSH service
RESTARTED=false
if command -v systemctl &>/dev/null; then
    if systemctl restart sshd &>/dev/null; then
        RESTARTED=true
    elif systemctl restart ssh &>/dev/null; then
        RESTARTED=true
    fi
elif command -v service &>/dev/null; then
    if service sshd restart &>/dev/null; then
        RESTARTED=true
    elif service ssh restart &>/dev/null; then
        RESTARTED=true
    fi
fi

if ! $RESTARTED; then
    echo "false"
    exit 1
fi

echo "true"
exit 0