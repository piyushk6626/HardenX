#!/bin/bash

CONFIG_FILE="/etc/sudoers.d/99-custom-logfile"

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

SUDO_LOG_FILE="$1"

if ! printf "Defaults    logfile=%s\n" "$SUDO_LOG_FILE" > "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

if ! chmod 0440 "$CONFIG_FILE"; then
    rm -f "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi

if visudo -c &>/dev/null; then
    echo "true"
    exit 0
else
    rm -f "$CONFIG_FILE" >/dev/null 2>&1
    echo "false"
    exit 1
fi