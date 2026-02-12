#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "false"
  exit 1
fi

PERMISSIONS="$1"
TARGET_DIR="/etc/cron.hourly"

if chmod "${PERMISSIONS}" "${TARGET_DIR}" &>/dev/null; then
  echo "true"
else
  echo "false"
fi