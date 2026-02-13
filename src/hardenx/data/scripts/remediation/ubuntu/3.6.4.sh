#!/usr/bin/env bash

if [[ "$#" -ne 3 ]]; then
    false
    exit 1
fi

PERMISSIONS="$1"
OWNER="$2"
GROUP="$3"
TARGET_DIR="/etc/cron.daily"

if chown "${OWNER}:${GROUP}" "${TARGET_DIR}" && chmod "${PERMISSIONS}" "${TARGET_DIR}"; then
    true
else
    false
fi