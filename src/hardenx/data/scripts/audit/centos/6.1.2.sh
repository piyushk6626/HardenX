#!/usr/bin/env bash

for key_file in /etc/ssh/ssh_host_*_key; do
    if [[ -f "$key_file" ]]; then
        stat -c "%n:%a:%U" "$key_file"
    fi
done