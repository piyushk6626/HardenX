#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

TARGET_DIR="/etc/cron.monthly"
INPUT="$1"

IFS=':' read -r permissions owner group <<< "$INPUT"

if [[ -z "$permissions" || -z "$owner" || -z "$group" ]]; then
    echo "false"
    exit 1
fi

if chmod "${permissions}" "${TARGET_DIR}" && \
   chown "${owner}" "${TARGET_DIR}" && \
   chgrp "${group}" "${TARGET_DIR}"; then
    echo "true"
else
    echo "false"
fi