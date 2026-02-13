#!/bin/bash

CONFIG_FILE="/etc/ssh/sshd_config"
OPTION="GSSAPIAuthentication"
VALUE="$1"

# Validate input
if [[ "$1" != "yes" && "$1" != "no" ]]; then
    echo "Usage: $0 <yes|no>" >&2
    echo "false"
    exit 1
fi

# Check for root privileges
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    echo "false"
    exit 1
fi

# Check if config file is writable
if [[ ! -w "$CONFIG_FILE" ]]; then
    echo "Error: Cannot write to $CONFIG_FILE." >&2
    echo "false"
    exit 1
fi

# Modify the configuration file
# Use grep to find if the option is present (commented or not)
if grep -qE "^[[:space:]]*#?[[:space:]]*${OPTION}" "$CONFIG_FILE"; then
    # If it exists, use sed to replace the entire line. This also uncomments the line.
    sed -i.bak "s/^[[:space:]]*#?[[:space:]]*${OPTION}.*/${OPTION} ${VALUE}/" "$CONFIG_FILE"
else
    # If it does not exist, append it to the end of the file.
    # Ensure there's a newline at the end before appending.
    [[ $(tail -c1 "$CONFIG_FILE") ]] && echo "" >> "$CONFIG_FILE"
    echo "${OPTION} ${VALUE}" >> "$CONFIG_FILE"
fi

# Verify that the change was successful before restarting the service
if ! grep -qE "^[[:space:]]*${OPTION}[[:space:]]+${VALUE}" "$CONFIG_FILE"; then
    echo "Error: Failed to modify $CONFIG_FILE." >&2
    echo "false"
    exit 1
fi

# Restart SSH service
# Try systemctl first, covering common service names (sshd, ssh)
if command -v systemctl &>/dev/null; then
    if systemctl is-active --quiet sshd; then
        systemctl restart sshd
    elif systemctl is-active --quiet ssh; then
        systemctl restart ssh
    else
        # Try to restart sshd even if inactive
        systemctl restart sshd || systemctl restart ssh
    fi
# Fallback to the 'service' command
elif command -v service &>/dev/null; then
    service sshd restart || service ssh restart
else
    echo "Error: Could not find systemctl or service to restart SSH." >&2
    # Revert change if service restart tool is not found
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" 2>/dev/null
    echo "false"
    exit 1
fi

# Check the exit status of the restart command
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to restart SSH service. Configuration change has been reverted." >&2
    # Revert the change if restart fails
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE" 2>/dev/null
    echo "false"
    exit 1
fi

# Clean up backup file on success
rm -f "${CONFIG_FILE}.bak"

echo "true"
exit 0