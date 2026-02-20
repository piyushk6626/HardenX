#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

RP_VALUE="$1"
CONF_FILE="/etc/sysctl.d/99-security-rp-filter.conf"
PARAMS=(
  "net.ipv4.conf.all.rp_filter"
  "net.ipv4.conf.default.rp_filter"
)

for param in "${PARAMS[@]}"; do
    if ! sysctl -w "${param}=${RP_VALUE}" &>/dev/null; then
        echo "false"
        exit 1
    fi
done

{
    echo "# Configuration set by script"
    for param in "${PARAMS[@]}"; do
        echo "${param} = ${RP_VALUE}"
    done
} > "$CONF_FILE"

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

echo "true"
exit 0