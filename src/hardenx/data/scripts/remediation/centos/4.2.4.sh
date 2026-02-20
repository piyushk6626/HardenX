#!/usr/bin/env bash

if [[ "$#" -ne 1 ]] || [[ "$1" != "Not Available" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

CONF_FILE="/etc/modprobe.d/sctp-disable.conf"
CONTENT="install sctp /bin/true"

if ! echo "$CONTENT" > "$CONF_FILE"; then
    echo "false"
    exit 1
fi

if lsmod | grep -q '^sctp\s'; then
    if ! modprobe -r sctp; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0