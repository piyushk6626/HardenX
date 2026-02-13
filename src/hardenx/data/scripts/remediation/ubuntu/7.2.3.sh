#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    exit 1
fi

new_umask="$1"
config_file="/etc/login.defs"

if ! [[ "$new_umask" =~ ^[0-7]{3,4}$ ]]; then
    exit 1
fi

if [ ! -f "$config_file" ] || [ ! -w "$config_file" ]; then
    exit 1
fi

if grep -q -E '^[[:space:]]*UMASK' "$config_file"; then
    sed -i.bak -E "s/^[[:space:]]*(UMASK[[:space:]]+).*/\1$new_umask/" "$config_file"
else
    printf "\nUMASK\t\t%s\n" "$new_umask" >> "$config_file"
fi

if [ $? -eq 0 ]; then
    exit 0 # true
else
    exit 1 # false
fi