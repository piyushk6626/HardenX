#!/bin/bash

# This script is intended to be run with root privileges to modify file ownership and permissions.

shopt -s nullglob
key_files=(/etc/ssh/ssh_host_*_key)

if [[ ${#key_files[@]} -eq 0 ]]; then
    echo "true"
    exit 0
fi

for key_file in "${key_files[@]}"; do
    if ! chown root "$key_file" || ! chmod 600 "$key_file"; then
        echo "false"
        exit 1
    fi
done

echo "true"
exit 0