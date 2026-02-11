#!/usr/bin/env bash

files_to_scan=(/etc/profile)
if [ -d /etc/profile.d ]; then
    files_to_scan+=(/etc/profile.d/*.sh)
fi

last_setting=$(cat "${files_to_scan[@]}" 2>/dev/null | grep -E "^\s*(export\s+)?TMOUT\s*=" | tail -n 1)

timeout_val=0

if [ -n "$last_setting" ]; then
    val_str=$(echo "$last_setting" | awk -F'=' '{print $2}')
    val_clean=$(echo "$val_str" | tr -d "[:space:]'\"")

    if [[ "$val_clean" =~ ^[1-9][0-9]*$ ]]; then
        timeout_val="$val_clean"
    fi
fi

echo "$timeout_val"