#!/bin/bash

FILE="/etc/gshadow-"

if [ -e "$FILE" ]; then
    stat -c "%a" "$FILE"
else
    echo 'Not Found'
fi