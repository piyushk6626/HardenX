#!/bin/bash

if [ -z "$1" ]; then
    echo "false"
    exit 1
fi

STATE="$1"
TARGET_FILE="/etc/shadow-"

if [ "$STATE" == "File not found" ]; then
    rm "$TARGET_FILE"
    EXIT_CODE=$?
else
    if ! read -r PERMISSIONS OWNERSHIP <<< "$STATE"; then
        echo "false"
        exit 1
    fi

    chmod "$PERMISSIONS" "$TARGET_FILE" && chown "$OWNERSHIP" "$TARGET_FILE"
    EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi