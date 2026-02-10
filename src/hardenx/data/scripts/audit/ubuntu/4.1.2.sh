#!/usr/bin/env bash

status=$(nmcli radio wifi 2>/dev/null)

if [[ "$status" == "enabled" ]]; then
  echo "enabled"
else
  echo "disabled"
fi