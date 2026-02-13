#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
KEY="MaxAuthTries"
VALUE="$1"

if [[ ! -f "$SSHD_CONFIG" ]] || [[ ! -w "$SSHD_CONFIG" ]]; then
    echo "false"
    exit 1
fi

if grep -qE "^[[:space:]]*#?[[:space:]]*${KEY}" "${SSHD_CONFIG}"; then
    sed -i "s/^[[:space:]]*#?[[:space:]]*${KEY}.*/${KEY} ${VALUE}/" "${SSHD_CONFIG}"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    if ! echo "${KEY} ${VALUE}" >> "${SSHD_CONFIG}"; then
        echo "false"
        exit 1
    fi
fi

if systemctl is-active --quiet sshd; then
    SERVICE_NAME="sshd"
elif systemctl is-active --quiet ssh; then
    SERVICE_NAME="ssh"
else
    SERVICE_NAME="sshd" # Default guess
fi

if ! systemctl restart "${SERVICE_NAME}" &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0