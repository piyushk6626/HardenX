#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   exit 1
fi

if [[ $# -ne 1 ]] || [[ "$1" != "disabled" ]]; then
    exit 1
fi

readonly CONF_FILE="/etc/modprobe.d/sctp-disabled.conf"

if ! echo "install sctp /bin/true" > "$CONF_FILE"; then
    exit 1
fi

if lsmod | grep -q -w "sctp"; then
    modprobe -r sctp 2>/dev/null || true
fi

exit 0