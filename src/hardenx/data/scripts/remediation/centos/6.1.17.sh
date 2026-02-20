#!/bin/bash

# Function to print false and exit
fail() {
    echo "false"
    exit 1
}

# Validate number of arguments
if [[ $# -ne 1 ]]; then
    fail
fi

# Validate argument is a non-negative integer
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    fail
fi

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    fail
fi

# Configuration
readonly MAX_SESSIONS_VALUE="$1"
readonly SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# Check if config file exists and is writable
if [[ ! -f "$SSH_CONFIG_FILE" ]] || [[ ! -w "$SSH_CONFIG_FILE" ]]; then
    fail
fi

# Modify the sshd_config file
# Check if the MaxSessions line already exists (commented or not)
if grep -qE "^\s*#?\s*MaxSessions\s+" "$SSH_CONFIG_FILE"; then
    # If it exists, replace it. Handles both commented and uncommented cases.
    sed -i -E "s/^\s*#?\s*MaxSessions\s+.*/MaxSessions ${MAX_SESSIONS_VALUE}/" "$SSH_CONFIG_FILE"
    # Check if sed command succeeded
    if [[ $? -ne 0 ]]; then
        fail
    fi
else
    # If it doesn't exist, add it to the end of the file.
    echo "MaxSessions ${MAX_SESSIONS_VALUE}" >> "$SSH_CONFIG_FILE"
    # Check if echo command succeeded
    if [[ $? -ne 0 ]]; then
        fail
    fi
fi

# Restart the sshd service to apply changes
if command -v systemctl &> /dev/null && systemctl is-active --quiet sshd.service; then
    systemctl restart sshd.service
    RESTART_STATUS=$?
elif command -v systemctl &> /dev/null && systemctl is-active --quiet ssh.service; then
    systemctl restart ssh.service
    RESTART_STATUS=$?
elif command -v service &> /dev/null; then
    service sshd restart &>/dev/null || service ssh restart &>/dev/null
    RESTART_STATUS=$?
else
    # Could not find a way to restart the service
    fail
fi

if [[ $RESTART_STATUS -ne 0 ]]; then
    fail
fi

echo "true"
exit 0