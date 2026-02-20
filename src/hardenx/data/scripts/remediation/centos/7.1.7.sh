#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <allowed_root_username>" >&2
    echo "false"
    exit 1
fi

readonly ALLOWED_ROOT_USER="$1"
COMPLIANT=true

mapfile -t uid_zero_users < <(getent passwd 0 | cut -d: -f1)
if [[ $? -ne 0 ]]; then
    logger "ERROR: Failed to read passwd database to find UID 0 users."
    echo "false"
    exit 1
fi

for username in "${uid_zero_users[@]}"; do
    if [[ "$username" != "$ALLOWED_ROOT_USER" ]]; then
        logger "AUDIT: Found illegitimate UID 0 account: '$username'. Attempting to lock password."
        
        if passwd -l "$username" &>/dev/null; then
            logger "ACTION: Successfully locked password for illegitimate UID 0 account: '$username'."
        else
            logger "ERROR: Failed to lock password for illegitimate UID 0 account: '$username'."
            COMPLIANT=false
            break
        fi
    fi
done

if [[ "$COMPLIANT" == "true" ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi