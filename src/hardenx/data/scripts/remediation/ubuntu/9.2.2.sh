#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != "lock" ]]; then
    echo "false"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

operation_successful=true

users_to_lock=$(awk -F: '$2 == "" {print $1}' /etc/shadow)

if [[ -z "$users_to_lock" ]]; then
    echo "true"
    exit 0
fi

for user in $users_to_lock; do
    passwd -l "$user" &>/dev/null
    if [[ $? -ne 0 ]]; then
        operation_successful=false
    fi
done

echo "$operation_successful"