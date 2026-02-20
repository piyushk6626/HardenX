#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 0
fi

input="$1"
target_dir="/etc/cron.daily"

colons_only=${input//[^:]/}
if [[ "$colons_only" != "::" ]]; then
    echo "false"
    exit 0
fi

IFS=':' read -r perms user group <<< "$input"

if [[ -z "$perms" || -z "$user" || -z "$group" ]]; then
    echo "false"
    exit 0
fi

if chmod "$perms" "$target_dir" &>/dev/null && chown "${user}:${group}" "$target_dir" &>/dev/null; then
    echo "true"
else
    echo "false"
fi