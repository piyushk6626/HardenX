#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ARG="$1"
REGEX="^[0-7]{3,4}/[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+$"

if ! [[ "$ARG" =~ $REGEX ]]; then
    echo "false"
    exit 1
fi

PERMISSIONS="${ARG%/*}"
OWNERSHIP="${ARG#*/}"

shopt -s nullglob
KEY_FILES=(/etc/ssh/ssh_host_*_key)

if [ ${#KEY_FILES[@]} -eq 0 ]; then
    echo "true"
    exit 0
fi

for key_file in "${KEY_FILES[@]}"; do
    if ! chmod "$PERMISSIONS" "$key_file" || ! chown "$OWNERSHIP" "$key_file"; then
        echo "false"
        exit 1
    fi
done

echo "true"
exit 0