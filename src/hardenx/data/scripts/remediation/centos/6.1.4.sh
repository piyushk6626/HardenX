#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="/etc/ssh/sshd_config"
DIRECTIVE="$1"
VALUE="$2"

if [[ $# -ne 2 || -z "$DIRECTIVE" || -z "$VALUE" ]]; then
    echo "Usage: $0 <Directive> \"<Value>\"" >&2
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   echo "false"
   exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file not found: $CONFIG_FILE" >&2
    echo "false"
    exit 1
fi

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

# Remove any existing instance of the directive, commented or not
grep -v -E "^\s*#?\s*${DIRECTIVE}\s+.*" "$CONFIG_FILE" > "$TMP_FILE"

# Add the new directive at the end of the file
echo "$DIRECTIVE $VALUE" >> "$TMP_FILE"

# Test the new configuration file for syntax errors
if ! sshd -t -f "$TMP_FILE" &>/dev/null; then
    echo "Failed: sshd_config syntax check failed." >&2
    echo "false"
    exit 1
fi

# Overwrite the original file with the new one
# Using install to preserve permissions and ownership
if ! install -m 600 -o root -g root "$TMP_FILE" "$CONFIG_FILE"; then
    echo "Failed: Could not write to $CONFIG_FILE" >&2
    echo "false"
    exit 1
fi

# Restart the SSH service
RESTARTED=false
if command -v systemctl &>/dev/null; then
    if systemctl restart sshd &>/dev/null || systemctl restart ssh &>/dev/null; then
        RESTARTED=true
    fi
elif command -v service &>/dev/null; then
    if service sshd restart &>/dev/null || service ssh restart &>/dev/null; then
        RESTARTED=true
    fi
fi

if [ "$RESTARTED" = false ]; then
    echo "Failed: Could not restart sshd service." >&2
    echo "false"
    exit 1
fi

echo "true"