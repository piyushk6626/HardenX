#!/bin/bash

TARGET_DIR="/var/log/journal"

if [ -d "$TARGET_DIR" ]; then
    stat -c "%a" "$TARGET_DIR"
else
    echo "not_found"
fi