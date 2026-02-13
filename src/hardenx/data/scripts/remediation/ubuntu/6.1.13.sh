#!/usr/bin/env bash

set -euo pipefail

fail() {
    echo "false"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
   fail
fi

if [[ $# -ne 1 ]]; then
   fail
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    fail
fi

LOGIN_GRACE_TIME="$1"
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -f "$SSHD_CONFIG_FILE" || ! -w "$SSHD_CONFIG_FILE" ]]; then
    fail
fi

# Use a temporary file for atomic operations, although sed -i is widely used
# We will use sed -i for simplicity as it's common in admin scripts.
if grep -qE '^[[:space:]]*#?[[:space:]]*LoginGraceTime' "$SSHD_CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*LoginGraceTime.*/LoginGraceTime $LOGIN_GRACE_TIME/" "$SSHD_CONFIG_FILE" || fail
else
    # Append a newline before adding the new config to ensure it's on a new line
    echo "" >> "$SSHD_CONFIG_FILE" || fail
    echo "LoginGraceTime $LOGIN_GRACE_TIME" >> "$SSHD_CONFIG_FILE" || fail
fi

# Restart the SSH service, trying common service names
if systemctl restart sshd &>/dev/null; then
    :
elif systemctl restart ssh &>/dev/null; then
    :
else
    fail
fi

echo "true"
exit 0