#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

target_dir="/etc/cron.monthly"

if [ ! -d "$target_dir" ]; then
    echo "false"
    exit 1
fi

state_arg="$1"
permissions="${state_arg%% *}"
ownership="${state_arg#* }"

if [ "$permissions" = "$ownership" ]; then
    echo "false"
    exit 1
fi

if chmod "$permissions" "$target_dir" && chown "$ownership" "$target_dir"; then
    echo "true"
else
    echo "false"
fi