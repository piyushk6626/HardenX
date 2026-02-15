#!/bin/bash

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

GROUP_NAME="$1"
TARGET_DIR="/var/log/audit/"

if chgrp -- "$GROUP_NAME" "$TARGET_DIR" &>/dev/null; then
    echo "true"
else
    echo "false"
fi