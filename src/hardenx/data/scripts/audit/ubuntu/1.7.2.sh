#!/bin/bash

if findmnt -n -o OPTIONS /var/log | grep -q '\bnodev\b'; then
  echo "Enabled"
else
  echo "Disabled"
fi