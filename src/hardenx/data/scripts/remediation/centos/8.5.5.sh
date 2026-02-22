#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo 'false'
    exit 1
fi

mode="$1"

if ! [[ "$mode" =~ ^[0-7]{3,4}$ ]]; then
    echo 'false'
    exit 1
fi

if find /etc/audit/ -type f -exec chmod "$mode" {} + &> /dev/null; then
    echo 'true'
else
    echo 'false'
fi