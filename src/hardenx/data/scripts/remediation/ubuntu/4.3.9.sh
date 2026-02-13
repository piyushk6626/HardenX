#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 || ! "$1" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

VALUE=$1
CONFIG_FILE="/etc/sysctl.d/99-security-settings.conf"
PARAM="net.ipv4.conf.all.log_martians"
PARAM_SETTING="${PARAM} = ${VALUE}"

# Ensure the target directory exists
mkdir -p "$(dirname "$CONFIG_FILE")"

if sysctl -w "${PARAM}=${VALUE}" &>/dev/null && echo "${PARAM_SETTING}" > "${CONFIG_FILE}"; then
    echo "true"
else
    echo "false"
fi