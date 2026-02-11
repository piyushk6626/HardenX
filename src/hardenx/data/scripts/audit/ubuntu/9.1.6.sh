#!/usr/bin/env bash

TARGET_FILE="/etc/shadow-"

if [ -f "$TARGET_FILE" ]; then
    stat -c "%a %U:%G" "$TARGET_FILE"
fi