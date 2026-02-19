#!/bin/bash

if modprobe --showconfig | grep -Eq '^\s*(install|blacklist)\s+hfsplus\b'; then
  echo "Disabled"
else
  echo "Enabled"
fi