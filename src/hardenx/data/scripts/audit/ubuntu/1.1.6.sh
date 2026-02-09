#!/bin/bash

if modprobe -n -v overlayfs 2>&1 | grep -q 'install /bin/true'; then
  echo "Disabled"
else
  echo "Enabled"
fi