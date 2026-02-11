#!/usr/bin/env bash

if [ -n "$(find /etc/audit/ -type f -perm /137 -print -quit 2>/dev/null)" ]; then
  echo "non-compliant"
else
  echo "compliant"
fi