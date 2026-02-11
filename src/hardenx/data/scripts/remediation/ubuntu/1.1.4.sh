#!/bin/bash

if [[ "$(id -u)" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ "$1" != "Disabled" ]]; then
  echo "false"
  exit 1
fi

CONF_FILE="/etc/modprobe.d/disable-hfsplus.conf"

echo "install hfsplus /bin/true" > "$CONF_FILE"
if [[ $? -ne 0 ]]; then
  echo "false"
  exit 1
fi

if lsmod | grep -q "^hfsplus\s"; then
  rmmod hfsplus
  if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
  fi
fi

echo "true"
exit 0