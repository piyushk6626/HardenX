#!/usr/bin/env bash

if findmnt --mountpoint /var/log &>/dev/null; then
  echo "true"
else
  echo "false"
fi