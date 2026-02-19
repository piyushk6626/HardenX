#!/usr/bin/env bash

timeout_value=0

last_setting=$(grep -E '^\s*(export\s+|readonly\s+)?TMOUT=' /etc/profile /etc/profile.d/* 2>/dev/null | tail -n 1)

if [[ -n "$last_setting" ]]; then
    extracted_value=$(echo "$last_setting" | sed -n 's/^[^=]*=\s*[^0-9]*\([0-9]\+\).*/\1/p')

    if [[ "$extracted_value" =~ ^[1-9][0-9]*$ ]]; then
        timeout_value="$extracted_value"
    fi
fi

echo "$timeout_value"