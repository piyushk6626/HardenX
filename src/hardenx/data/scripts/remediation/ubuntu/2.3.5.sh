#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

TARGET_FILE="/etc/issue.net"
permissions="${1%% *}"
ownership="${1#* }"

if [[ "$permissions" == "$1" ]] || [[ "$ownership" == "$1" ]]; then
    false
    exit 1
fi

if [[ ! -e "$TARGET_FILE" ]]; then
    false
    exit 1
fi

if chmod "$permissions" "$TARGET_FILE" && chown "$ownership" "$TARGET_FILE"; then
    true
else
    false
fi