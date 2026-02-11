#!/bin/bash

PARAM="kernel.yama.ptrace_scope"
CONFIG_FILE="/etc/sysctl.d/99-ptrace-scope.conf"

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"

if ! [[ "$VALUE" =~ ^[0-3]$ ]]; then
    echo "false"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Apply setting for the current session
if ! sysctl -w "${PARAM}=${VALUE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Make setting persistent
if grep -q -E "^\s*${PARAM}\s*=" "$CONFIG_FILE" 2>/dev/null; then
    # Entry exists, so replace it
    if ! sed -i "s/^\s*${PARAM}\s*=.*/${PARAM} = ${VALUE}/" "$CONFIG_FILE"; then
        echo "false"
        exit 1
    fi
else
    # Entry does not exist, so add it
    if ! echo "${PARAM} = ${VALUE}" >> "$CONFIG_FILE"; then
        echo "false"
        exit 1
    fi
fi

# Reload system-wide sysctl settings to verify and apply
if ! sysctl --system &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0