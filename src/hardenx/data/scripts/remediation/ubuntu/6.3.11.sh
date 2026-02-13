#!/bin/bash

TARGET_FILE="/etc/security/pwquality.conf"
VALUE="$1"

# Validate input and permissions
if [[ $# -ne 1 ]] || ! [[ "$VALUE" =~ ^[0-9]+$ ]] || [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Validate target file
if [[ ! -f "$TARGET_FILE" ]] || [[ ! -w "$TARGET_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the parameter already exists (commented or uncommented)
if grep -qE '^[#\s]*difok\s*=' "$TARGET_FILE"; then
    # Update the existing line
    sed -i "s/^[#\s]*difok\s*=.*/difok = $VALUE/" "$TARGET_FILE"
else
    # Add the new line
    echo "difok = $VALUE" >> "$TARGET_FILE"
fi

# Verify success of the last command
if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi