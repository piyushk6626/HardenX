#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

PARAM_NAME="net.ipv6.conf.all.disable_ipv6"
PARAM_VALUE="$1"
CONF_FILE="/etc/sysctl.d/99-sysctl.conf"

# Apply the setting to the running configuration
if ! sysctl -w "${PARAM_NAME}=${PARAM_VALUE}" >/dev/null 2>&1; then
    echo "false"
    exit 1
fi

# Ensure the configuration file and its directory exist
if ! [ -d "$(dirname "$CONF_FILE")" ]; then
    mkdir -p "$(dirname "$CONF_FILE")" || { echo "false"; exit 1; }
fi
touch "$CONF_FILE" || { echo "false"; exit 1; }

# Make the setting persistent
if grep -qE "^\s*${PARAM_NAME}\s*=" "$CONF_FILE"; then
    # If the parameter exists, update it
    if ! sed -i "s/^\s*${PARAM_NAME}\s*=.*/${PARAM_NAME} = ${PARAM_VALUE}/" "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
else
    # If the parameter does not exist, append it
    if ! echo "${PARAM_NAME} = ${PARAM_VALUE}" >> "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0