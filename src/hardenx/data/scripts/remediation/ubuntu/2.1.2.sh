#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

TARGET_FILE="/boot/grub/grub.cfg"

if [ ! -f "$TARGET_FILE" ]; then
    echo "false"
    exit 1
fi

read -r ownership permissions <<< "$1"

if [[ -z "$ownership" || -z "$permissions" ]]; then
    echo "false"
    exit 1
fi

if chown "$ownership" "$TARGET_FILE" 2>/dev/null && chmod "$permissions" "$TARGET_FILE" 2>/dev/null; then
    echo "true"
else
    echo "false"
fi