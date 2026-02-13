#!/bin/bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
CONF_FILE="/etc/sysctl.d/99-secure-redirects-custom.conf"
KEY1="net.ipv4.conf.all.secure_redirects"
KEY2="net.ipv4.conf.default.secure_redirects"

# Set runtime values and check for success
if ! sysctl -w "${KEY1}=${VALUE}" &>/dev/null || ! sysctl -w "${KEY2}=${VALUE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Make settings persistent and check for success
if ! printf "%s = %s\n%s = %s\n" "$KEY1" "$VALUE" "$KEY2" "$VALUE" > "$CONF_FILE"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0