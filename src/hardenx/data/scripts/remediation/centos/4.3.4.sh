#!/usr/bin/env bash

# This script sets the 'net.ipv4.icmp_echo_ignore_broadcasts' kernel parameter.
# It requires one argument: the desired state (0 or 1).
# It must be run as root.

set -e
set -o pipefail

fail() {
    echo "false"
    exit 1
}

PARAM_NAME="net.ipv4.icmp_echo_ignore_broadcasts"
CONFIG_FILE="/etc/sysctl.d/99-icmp-broadcast.conf"
DESIRED_VALUE="$1"

# --- Validation ---

# 1. Check for root privileges
if [[ "$EUID" -ne 0 ]]; then
   fail
fi

# 2. Check for correct number of arguments
if [ "$#" -ne 1 ]; then
    fail
fi

# 3. Validate the argument is a 0 or 1
if ! [[ "$DESIRED_VALUE" =~ ^[01]$ ]]; then
    fail
fi

# --- Execution ---

# Apply the setting to the live kernel
sysctl -w "${PARAM_NAME}=${DESIRED_VALUE}" &>/dev/null || fail

# Ensure the configuration directory exists
mkdir -p "$(dirname "$CONFIG_FILE")" || fail

# Make the setting persistent by adding/modifying the config file
# Use a temporary file for an atomic write operation
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT HUP INT QUIT TERM

# Filter out the old setting if the config file exists
if [ -f "$CONFIG_FILE" ]; then
    grep -v "^\s*${PARAM_NAME}\s*=" "$CONFIG_FILE" > "$TMP_FILE"
fi

# Add the new setting
echo "${PARAM_NAME} = ${DESIRED_VALUE}" >> "$TMP_FILE"

# Atomically replace the old config file with the new one
mv "$TMP_FILE" "$CONFIG_FILE" || fail

# Set appropriate permissions
chmod 644 "$CONFIG_FILE" || fail

# --- Success ---

echo "true"
exit 0