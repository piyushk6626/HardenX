#!/bin/bash

if findmnt --target /var/tmp &>/dev/null; then
  echo "mounted"
else
  echo "not mounted"
fi