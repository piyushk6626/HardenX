#!/usr/bin/env bash

root_device=$(findmnt -n -o SOURCE --target /)
var_device=$(findmnt -n -o SOURCE --target /var)

if [[ "$root_device" == "$var_device" ]]; then
  echo "false"
else
  echo "true"
fi