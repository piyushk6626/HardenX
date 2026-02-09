#!/bin/bash

if [[ "$(modprobe -n -v usb-storage 2>/dev/null)" == "install /bin/true" ]]; then
  echo "Disabled"
else
  echo "Enabled"
fi