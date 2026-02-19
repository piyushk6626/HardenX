#!/bin/bash

FILE="/etc/shadow-"

if [ -f "$FILE" ]; then
    stat -c "%a %U:%G" "$FILE"
else
    echo 'File not found'
fi