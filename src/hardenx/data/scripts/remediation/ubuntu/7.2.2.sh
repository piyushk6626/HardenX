#!/bin/bash

CONFIG_FILE="/etc/profile.d/cis_shell_timeout.sh"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Check for exactly one argument
if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

TIMEOUT_VAL="$1"

# Validate argument is a non-negative integer
if ! [[ "$TIMEOUT_VAL" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

# Create configuration file and set permissions
# Use a subshell to ensure atomicity of the checks
(
    printf "export TMOUT=%s\n" "$TIMEOUT_VAL" >| "$CONFIG_FILE" && \
    chmod 644 "$CONFIG_FILE"
)

if [[ $? -eq 0 ]]; then
    echo "true"
else
    # Attempt cleanup on failure
    rm -f "$CONFIG_FILE" &>/dev/null
    echo "false"
fi