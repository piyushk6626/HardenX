#!/usr/bin/env bash

if findmnt -n -o OPTIONS --target /var/log/audit 2>/dev/null | grep -q '\bnoexec\b'; then
    echo "Enabled"
else
    echo "Disabled"
fi