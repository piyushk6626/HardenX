#!/usr/bin/env bash

if [[ "$#" -ne 1 || -z "$1" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

KEX_ALGORITHMS="$1"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -w "$SSH_CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -qiE "^[[:space:]]*KexAlgorithms" "$SSH_CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*KexAlgorithms.*/KexAlgorithms ${KEX_ALGORITHMS}/i" "$SSH_CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    {
        echo ""
        echo "KexAlgorithms ${KEX_ALGORITHMS}"
    } >> "$SSH_CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

sshd -t &>/dev/null
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

systemctl restart sshd &>/dev/null
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

echo "true"