#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

GROUP_NAME="$1"
TARGET_DIR="/etc/audit/rules.d"

if [[ ! -d "${TARGET_DIR}" ]] || ! getent group "${GROUP_NAME}" &>/dev/null; then
    echo "false"
    exit 1
fi

if find "${TARGET_DIR}" -maxdepth 1 -type f -exec chgrp -- "${GROUP_NAME}" {} + &>/dev/null; then
    echo "true"
else
    echo "false"
fi