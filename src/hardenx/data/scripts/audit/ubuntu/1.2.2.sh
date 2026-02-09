#!/usr/bin/env bash

if findmnt -n -o OPTIONS /tmp | grep -qw 'nodev'; then
  echo "set"
else
  echo "not set"
fi