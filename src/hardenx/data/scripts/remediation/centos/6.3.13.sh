#!/bin/bash

CONFIG_FILE="/etc/security/pwquality.conf"
SETTING_KEY="maxrepeat"

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"

if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    # If the file doesn't exist, we can't modify it.
    # Creating it might be out of scope, so we fail.
    echo "false"
    exit 1
fi

# Check if the setting already exists (even if commented out)
if grep -qE "^\s*#?\s*${SETTING_KEY}\s*=" "$CONFIG_FILE"; then
    # It exists, so we use sed to find and replace the line.
    # This handles both commented and uncommented cases and sets the new value.
    if sed -i "s/^\s*#?\s*${SETTING_KEY}\s*=.*/${SETTING_KEY} = ${VALUE}/" "$CONFIG_FILE"; then
        echo "true"
    else
        echo "false"
    fi
else
    # It does not exist, so we append it to the end of the file.
    if echo "${SETTING_KEY} = ${VALUE}" >> "$CONFIG_FILE"; then
        echo "true"
    else
        echo "false"
    fi
fi