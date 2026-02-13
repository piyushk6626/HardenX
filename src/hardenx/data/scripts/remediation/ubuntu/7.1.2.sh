#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

readonly LOGIN_DEFS_FILE="/etc/login.defs"
readonly PARAM="PASS_MIN_DAYS"
readonly NEW_VALUE="$1"

if [[ ! -w "$LOGIN_DEFS_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*${PARAM}\s+" "$LOGIN_DEFS_FILE"; then
    sed -i -E "s/^\s*(${PARAM}\s+)[0-9]+/\1${NEW_VALUE}/" "$LOGIN_DEFS_FILE"
    if [[ $? -eq 0 ]]; then
        echo "true"
    else
        echo "false"
    fi
else
    # Parameter not found, append it
    echo "${PARAM}    ${NEW_VALUE}" >> "$LOGIN_DEFS_FILE"
    if [[ $? -eq 0 ]]; then
        echo "true"
    else
        echo "false"
    fi
fi