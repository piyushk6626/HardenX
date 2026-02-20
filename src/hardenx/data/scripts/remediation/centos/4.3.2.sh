#!/usr/bin/env bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

VALUE=$1
CONF_FILE="/etc/sysctl.d/99-ipv4-redirects.conf"
PARAM1="net.ipv4.conf.all.send_redirects"
PARAM2="net.ipv4.conf.default.send_redirects"

# Apply settings to the running configuration
if ! sysctl -w "${PARAM1}=${VALUE}" "${PARAM2}=${VALUE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Persist the settings by writing to a configuration file
# The redirection with a command group ensures the file is written atomically.
if ! {
    echo "${PARAM1} = ${VALUE}"
    echo "${PARAM2} = ${VALUE}"
} > "${CONF_FILE}"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0