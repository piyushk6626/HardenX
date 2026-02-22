#!/bin/bash

permissions="$1"
target_file="/etc/security/opasswd"

if [ ! -f "$target_file" ]; then
    echo "false"
    exit 0
fi

if chown root:root "$target_file" && chmod "$permissions" "$target_file"; then
    echo "true"
else
    echo "false"
fi