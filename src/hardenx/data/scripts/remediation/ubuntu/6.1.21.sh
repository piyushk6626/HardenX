#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to be called on script failure
on_failure() {
    echo "false"
    exit 1
}

trap on_failure ERR

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Check if the required positional argument is provided
if [ -z "$1" ]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

if [ ! -f "$SSH_CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

# Check if the setting already exists (commented or uncommented)
if grep -qE '^\s*#?\s*PermitUserEnvironment' "$SSH_CONFIG_FILE"; then
    # It exists, so we replace it (this also handles uncommenting)
    sed -i "s/^\s*#?\s*PermitUserEnvironment.*/PermitUserEnvironment ${DESIRED_STATE}/" "$SSH_CONFIG_FILE"
else
    # It does not exist, so we add it to the end of the file
    echo "PermitUserEnvironment ${DESIRED_STATE}" >> "$SSH_CONFIG_FILE"
fi

# Restart the SSH service to apply the new configuration
systemctl restart sshd

echo "true"