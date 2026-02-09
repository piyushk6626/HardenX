#!/usr/bin/env bash

if findmnt -n -o OPTIONS --target /var/log/audit | grep -q '\bnoexec\b'; then
    echo "Enabled"
else
    echo "Disabled"
fi