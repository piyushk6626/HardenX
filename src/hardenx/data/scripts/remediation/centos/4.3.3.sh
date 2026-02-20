#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

STATE="$1"
PARAM="net.ipv4.icmp_ignore_bogus_error_responses"
CONF_FILE="/etc/sysctl.d/99-icmp-ignore-bogus.conf"

if [[ "${STATE}" != "0" && "${STATE}" != "1" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if ! sysctl -w "${PARAM}=${STATE}" &>/dev/null; then
    echo "false"
    exit 1
fi

if ! echo "${PARAM} = ${STATE}" > "${CONF_FILE}"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0