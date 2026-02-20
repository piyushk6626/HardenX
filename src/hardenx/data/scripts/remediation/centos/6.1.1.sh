#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

read -r permissions owner group extra <<< "$1"

TARGET_FILE="/etc/ssh/sshd_config"

if [[ -z "$permissions" || -z "$owner" || -z "$group" || -n "$extra" || ! -f "$TARGET_FILE" ]]; then
    echo "false"
    exit 1
fi

if chmod "$permissions" "$TARGET_FILE" 2>/dev/null && chown "${owner}:${group}" "$TARGET_FILE" 2>/dev/null; then
    echo "true"
else
    echo "false"
fi