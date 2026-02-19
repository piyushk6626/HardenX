#!/bin/bash

FILE_PATH="/etc/security/opasswd"

if [ -f "$FILE_PATH" ]; then
    stat -c "%a" "$FILE_PATH"
else
    echo "Not Found"
fi