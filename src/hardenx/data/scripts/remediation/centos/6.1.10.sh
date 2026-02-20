#!/usr/bin/env bash

if [[ "$1" != "yes" && "$1" != "no" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
DIRECTIVE="HostbasedAuthentication"
VALUE="$1"

if [ ! -w "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

# Case 1: Directive exists and is active.
if grep -qE "^[[:space:]]*${DIRECTIVE}[[:space:]]+" "$CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*(${DIRECTIVE}[[:space:]]+).*/\1${VALUE}/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
# Case 2: Directive exists but is commented out.
elif grep -qE "^[[:space:]]*#[[:space:]]*${DIRECTIVE}[[:space:]]+" "$CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*#[[:space:]]*${DIRECTIVE}.*/${DIRECTIVE} ${VALUE}/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
# Case 3: Directive does not exist.
else
    echo "" >> "$CONFIG_FILE"
    echo "${DIRECTIVE} ${VALUE}" >> "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0