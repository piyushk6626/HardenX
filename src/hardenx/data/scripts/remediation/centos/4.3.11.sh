#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$1" != "0" && "$1" != "1" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

value="$1"
conf_file="/etc/sysctl.d/99-ipv6-accept-ra-custom.conf"
params=(
    "net.ipv6.conf.all.accept_ra"
    "net.ipv6.conf.default.accept_ra"
)

# Apply runtime settings
for param in "${params[@]}"; do
    if ! sysctl -w "${param}=${value}" &>/dev/null; then
        echo "false"
        exit 1
    fi
done

# Create persistent configuration
{
    echo "# Managed by script"
    echo "${params[0]} = ${value}"
    echo "${params[1]} = ${value}"
} > "$conf_file"

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

echo "true"
exit 0