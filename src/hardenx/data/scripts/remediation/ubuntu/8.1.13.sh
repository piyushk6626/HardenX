#!/usr/bin/env bash

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-7]{3}$ ]]; then
    echo "false"
    exit 1
fi

mode="$1"
target_dir="/var/log/"

if chown -R root:adm "$target_dir" && find "$target_dir" -type f -exec chmod "$mode" {} +; then
    echo "true"
else
    echo "false"
fi