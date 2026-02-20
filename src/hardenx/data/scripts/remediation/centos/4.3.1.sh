#!/usr/bin/env bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

STATE="$1"
SYSCTL_VAR="net.ipv4.ip_forward"
SYSCTL_CONF_FILE="/etc/sysctl.d/99-custom-ip-forward.conf"

# Set the runtime parameter. Suppress command output.
if ! sysctl -w "${SYSCTL_VAR}=${STATE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Make the setting persistent. This approach is idempotent.
# First, escape the variable name for use in sed's regex.
VAR_ESC=$(printf '%s\n' "$SYSCTL_VAR" | sed 's/[.[]*^$]/\\&/g')

# If the config file exists, remove any existing lines for our variable.
if [ -f "$SYSCTL_CONF_FILE" ]; then
    if ! sed -i "/^\s*${VAR_ESC}\s*=/d" "$SYSCTL_CONF_FILE"; then
        echo "false"
        exit 1
    fi
fi

# Append the correct new line to the config file (creates the file if it doesn't exist).
if ! echo "${SYSCTL_VAR} = ${STATE}" >> "$SYSCTL_CONF_FILE"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0