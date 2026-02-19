#!/bin/bash

if modprobe --showconfig | grep -Eq '^\s*(install\s+usb-storage\s+/(bin/true|bin/false)|blacklist\s+usb-storage)'; then
  echo "Disabled"
else
  echo "Enabled"
fi