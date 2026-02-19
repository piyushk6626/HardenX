#!/bin/bash

if findmnt -n -o OPTIONS --target /var/tmp | grep -q '\bnodev\b'; then
  echo "Enabled"
else
  echo "Disabled"
fi