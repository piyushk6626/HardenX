#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

MODE="$1"

if ! [[ "$MODE" =~ ^0[0-7]{3}$ ]]; then
    echo "false"
    exit 1
fi

TARGET_DIR="/etc/audit/"

if ! [[ -d "$TARGET_DIR" ]]; then
    echo "false"
    exit 1
fi

if find "$TARGET_DIR" -type f -exec chmod "$MODE" {} + &> /dev/null; then
    echo "true"
else
    echo "false"
fi