#!/bin/bash

if modprobe --showconfig | grep -q "install hfsplus /bin/true"; then
  echo "Disabled"
else
  echo "Enabled"
fi