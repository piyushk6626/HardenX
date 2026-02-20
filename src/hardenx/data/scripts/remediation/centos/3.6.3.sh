#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "false"
    exit 1
fi

PERMISSIONS="$1"
OWNER="$2"
GROUP="$3"
TARGET_DIR="/etc/cron.hourly"

if chmod "${PERMISSIONS}" "${TARGET_DIR}" && chown "${OWNER}":"${GROUP}" "${TARGET_DIR}"; then
    echo "true"
else
    echo "false"
fi