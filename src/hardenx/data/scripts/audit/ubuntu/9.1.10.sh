#!/bin/bash

FILE="/etc/security/opasswd"

if [ -f "$FILE" ]; then
    stat -c "%U:%G %a" "$FILE"
else
    echo "Not Configured"
fi