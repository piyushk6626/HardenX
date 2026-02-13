#!/bin/bash

if [[ "$1" != "disabled" ]]; then
    exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

CONF_FILE="/etc/modprobe.d/dccp_disable.conf"

if ! echo "install dccp /bin/true" > "$CONF_FILE"; then
    echo "false"
    exit 1
fi

if lsmod | grep -q -w "dccp"; then
    modprobe -r dccp &>/dev/null
fi

echo "true"
exit 0