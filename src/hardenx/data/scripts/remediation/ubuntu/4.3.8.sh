#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"

if ! [[ "${DESIRED_STATE}" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

PARAM_ALL="net.ipv4.conf.all.accept_source_route"
PARAM_DEFAULT="net.ipv4.conf.default.accept_source_route"
CONFIG_FILE="/etc/sysctl.d/60-accept-source-route.conf"

# Apply the setting to the running kernel
if ! sysctl -w "${PARAM_ALL}=${DESIRED_STATE}" &>/dev/null || \
   ! sysctl -w "${PARAM_DEFAULT}=${DESIRED_STATE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Create or update the configuration file for persistence
if ! {
    echo "# Controls acceptance of source-routed packets"
    echo "${PARAM_ALL} = ${DESIRED_STATE}"
    echo "${PARAM_DEFAULT} = ${DESIRED_STATE}"
} > "${CONFIG_FILE}"; then
    echo "false"
    exit 1
fi

echo "true"