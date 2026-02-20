#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

TARGET_DIR="/etc/cron.weekly"
INPUT_STRING="$1"

IFS=':' read -r permissions user group extra <<< "$INPUT_STRING"

if [ -z "$permissions" ] || [ -z "$user" ] || [ -z "$group" ] || [ -n "$extra" ]; then
    echo "false"
    exit 1
fi

if chmod "$permissions" "$TARGET_DIR" && \
   chown "$user" "$TARGET_DIR" && \
   chgrp "$group" "$TARGET_DIR"; then
    echo "true"
else
    echo "false"
fi