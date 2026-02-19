#!/usr/bin/env bash

if findmnt -n -o OPTIONS --target /home 2>/dev/null | grep -qw 'nodev'; then
  echo "nodev"
else
  echo "not_set"
fi