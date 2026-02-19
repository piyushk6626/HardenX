#!/bin/bash

FILE_PATH="/etc/gshadow-"

if [ -e "$FILE_PATH" ]; then
    stat -c "%a" "$FILE_PATH"
else
    echo "not_found"
fi