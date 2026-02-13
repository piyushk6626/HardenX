#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

max_sessions=$1
config_file="/etc/ssh/sshd_config"
new_line="MaxSessions ${max_sessions}"

if [[ ! -w "$config_file" ]]; then
    echo "false"
    exit 1
fi

if grep -qE '^\s*#?\s*MaxSessions\s+' "$config_file"; then
    sed -i -E "s/^\s*#?\s*MaxSessions\s+.*/${new_line}/" "$config_file"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    echo "${new_line}" >> "$config_file"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

if systemctl restart sshd &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi