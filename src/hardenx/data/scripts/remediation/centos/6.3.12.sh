#!/usr/bin/env bash

# This script sets the 'minlen' value in /etc/security/pwquality.conf.
# It requires a single numeric argument for the new minlen value.
# The script must be run with root privileges.

CONF_FILE="/etc/security/pwquality.conf"
NEW_VALUE="$1"

# --- Validation ---

# 1. Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# 2. Check for correct number of arguments
if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

# 3. Check if the argument is a non-negative integer
if ! [[ "$NEW_VALUE" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

# 4. Check if the configuration file exists and is writable
if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

# --- Logic ---

# Check if a 'minlen' line (commented or uncommented) already exists
if grep -qE '^\s*#?\s*minlen\s*=' "$CONF_FILE"; then
    # If it exists, use sed to replace it. This will also uncomment the line if needed.
    sed -i -E "s/^\s*#?\s*minlen\s*=.*/minlen = $NEW_VALUE/" "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    # If it does not exist, append it to the end of the file.
    echo "minlen = $NEW_VALUE" >> "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# --- Verification ---

# Verify that the value was set correctly
if grep -qE "^\s*minlen\s*=\s*$NEW_VALUE\s*$" "$CONF_FILE"; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi