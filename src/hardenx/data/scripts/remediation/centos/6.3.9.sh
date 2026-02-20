#!/usr/bin/env bash

CONFIG_FILE="/etc/security/faillock.conf"
UNLOCK_TIME=$1

if [[ $EUID -ne 0 ]]; then
   false
   exit 1
fi

if [[ "$#" -ne 1 ]] || ! [[ "$UNLOCK_TIME" =~ ^[0-9]+$ ]]; then
    false
    exit 1
fi

temp_file=$(mktemp)
if [ $? -ne 0 ]; then
    false
    exit 1
fi
trap 'rm -f "$temp_file"' EXIT

if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$temp_file"
fi

if grep -qE '^\s*unlock_time\s*=' "$temp_file"; then
    sed -i "s/^\s*unlock_time\s*=.*/unlock_time = $UNLOCK_TIME/" "$temp_file"
else
    echo "unlock_time = $UNLOCK_TIME" >> "$temp_file"
fi

if [ $? -eq 0 ]; then
    if ! mv "$temp_file" "$CONFIG_FILE"; then
        false
    else
        true
    fi
else
    false
fi