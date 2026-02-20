#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

USERNAME="$1"
CONFIG_FILE="/etc/sysconfig/chronyd"

if [[ ! -f "$CONFIG_FILE" || ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

if ! grep -q '^OPTIONS=' "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

# Use a temporary file for atomic operation
TMP_FILE=$(mktemp)
if [[ -z "$TMP_FILE" ]]; then
    echo "false"
    exit 1
fi

# 1. Remove any existing '-u <user>' from the OPTIONS line.
# 2. Add the new '-u <username>' to the end of the OPTIONS string.
# This handles cases where -u does not exist, or exists one or more times.
sed '/^OPTIONS=/ { s/ -u \S*//g; s/"$/ -u '"$USERNAME"'"/; }' "$CONFIG_FILE" > "$TMP_FILE"

if [[ $? -eq 0 && -s "$TMP_FILE" ]]; then
    # Check if the change was actually made to avoid unnecessary writes
    if ! cmp -s "$CONFIG_FILE" "$TMP_FILE"; then
        if ! mv "$TMP_FILE" "$CONFIG_FILE"; then
            rm -f "$TMP_FILE"
            echo "false"
            exit 1
        fi
    else
        rm -f "$TMP_FILE"
    fi
    echo "true"
else
    rm -f "$TMP_FILE"
    echo "false"
    exit 1
fi