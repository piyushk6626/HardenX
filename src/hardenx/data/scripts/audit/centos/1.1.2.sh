#!/bin/bash

if modprobe --showconfig | grep -q -E '^\s*install\s+freevxfs\s+/bin/true\s*$'; then
  echo "disabled"
else
  echo "enabled"
fi