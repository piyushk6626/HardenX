#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/security/pwquality.conf"
SETTING="dictcheck"
VALUE="$1"

if [[ ! -f "$CONFIG_FILE" || ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the setting already exists (commented or not)
if grep -qE "^\s*#?\s*${SETTING}\s*=" "$CONFIG_FILE"; then
    # It exists, so we replace it. The 'c' command in sed is good for replacing the whole line.
    # Using a different separator for sed to avoid issues if VALUE contains '/'
    sed -i -E "/^\s*#?\s*${SETTING}\s*=/c\\${SETTING} = ${VALUE}" "$CONFIG_FILE"
else
    # It does not exist, so we append it to the end of the file.
    echo "${SETTING} = ${VALUE}" >> "$CONFIG_FILE"
fi

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi
