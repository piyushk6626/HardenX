#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

DESIRED_STATE="$1"
CONFIG_FILE="/etc/ssh/sshd_config"
SETTING="PermitEmptyPasswords"

# Use a temporary file for sed to ensure atomic operation and handle permissions
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

if grep -q -E "^[#\s]*${SETTING}" "$CONFIG_FILE"; then
    sed -E "s/^[#\s]*${SETTING}.*/${SETTING} ${DESIRED_STATE}/" "$CONFIG_FILE" > "$TMP_FILE"
else
    cp "$CONFIG_FILE" "$TMP_FILE"
    echo "${SETTING} ${DESIRED_STATE}" >> "$TMP_FILE"
fi

if ! mv "$TMP_FILE" "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

# Ensure correct permissions and ownership
chown root:root "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

# Reload/Restart SSH service and output result
if (command -v systemctl &>/dev/null && (systemctl reload-or-restart sshd &>/dev/null || systemctl reload-or-restart ssh &>/dev/null)) || \
   (command -v service &>/dev/null && (service sshd restart &>/dev/null || service ssh restart &>/dev/null)); then
    echo "true"
else
    echo "false"
fi