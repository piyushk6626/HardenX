#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to handle failures
fail() {
    echo "false"
    exit 1
}

# --- Validation ---
# 1. Check for the correct number of arguments
if [[ $# -ne 2 ]]; then
    fail
fi

# 2. Check if arguments are non-negative integers
if ! [[ "$1" =~ ^[0-9]+$ ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
    fail
fi

# 3. Check for root privileges
if [[ $EUID -ne 0 ]]; then
   fail
fi

# --- Configuration ---
INTERVAL="$1"
COUNT_MAX="$2"
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

# 4. Check if the config file exists
if [[ ! -f "$SSHD_CONFIG_FILE" ]]; then
    fail
fi

# --- Modification ---
# Use a trap to ensure we print false on any error from this point on
trap fail ERR

# Create a timestamped backup of the original file
cp "$SSHD_CONFIG_FILE" "${SSHD_CONFIG_FILE}.bak_$(date +%s)"

# Remove any existing ClientAliveInterval and ClientAliveCountMax lines (commented or not)
# This prevents duplicates and ensures our new settings are the only ones.
sed -i -E \
    -e '/^[[:space:]]*#?[[:space:]]*ClientAliveInterval[[:space:]]+.*$/d' \
    -e '/^[[:space:]]*#?[[:space:]]*ClientAliveCountMax[[:space:]]+.*$/d' \
    "$SSHD_CONFIG_FILE"

# Add the new settings to the end of the file
cat <<EOF >> "$SSHD_CONFIG_FILE"

# Settings managed by script on $(date)
ClientAliveInterval $INTERVAL
ClientAliveCountMax $COUNT_MAX
EOF

# --- Apply Changes ---
# Restart the SSH service to apply changes. Check for systemd first.
if command -v systemctl &> /dev/null && systemctl list-units --type=service | grep -q 'sshd.service'; then
    systemctl restart sshd
elif command -v service &> /dev/null; then
    service sshd restart
elif [ -f /etc/init.d/sshd ]; then
    /etc/init.d/sshd restart
elif [ -f /etc/init.d/ssh ]; then
    /etc/init.d/ssh restart
else
    # Could not find a way to restart the service
    fail
fi

# --- Success ---
# If all commands succeeded, unset the trap and print true
trap - ERR
echo "true"
exit 0