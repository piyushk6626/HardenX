#!/usr/bin/env bash

CONFIG_FILE="/etc/security/pwquality.conf"
VALUE=$1

# --- Validation Checks ---

# Must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Check for exactly one argument
if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

# Check if the argument is a non-negative integer
if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

# Check if config file exists and is writable
if [[ ! -f "$CONFIG_FILE" ]] || [[ ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# --- Modification Logic ---

# Check if the maxclass setting (commented or not) already exists
if grep -qE '^\s*#?\s*maxclass\s*=' "$CONFIG_FILE"; then
    # It exists, so replace it.
    sed -i -E "s/^\s*#?\s*maxclass\s*=.*/maxclass = $VALUE/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    # It doesn't exist, so append it.
    echo "maxclass = $VALUE" >> "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# --- Verification ---

# Verify that the change was successful
if grep -qE "^\s*maxclass\s*=\s*$VALUE\s*$" "$CONFIG_FILE"; then
    echo "true"
else
    echo "false"
fi