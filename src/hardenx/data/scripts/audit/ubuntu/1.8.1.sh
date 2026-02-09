#!/bin/bash

if mountpoint -q /var/log/audit; then
  echo "Mounted"
else
  echo "Not Mounted"
fi