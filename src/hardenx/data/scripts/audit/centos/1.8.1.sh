#!/bin/bash

if findmnt --mountpoint /var/log/audit &>/dev/null; then
  echo "mounted"
else
  echo "not mounted"
fi