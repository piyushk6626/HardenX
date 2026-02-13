#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

input="$1"
target_dir="/etc/cron.weekly"

if ! [[ "$input" =~ ^[^:]+:[^:]+:[^:]+$ ]]; then
    echo "false"
    exit 1
fi

IFS=':' read -r permissions owner group <<< "$input"

if [ ! -d "$target_dir" ]; then
    echo "false"
    exit 1
fi

if chmod "$permissions" "$target_dir" &>/dev/null && chown "${owner}:${group}" "$target_dir" &>/dev/null; then
    echo "true"
else
    echo "false"
fi