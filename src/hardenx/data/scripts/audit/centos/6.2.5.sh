#!/usr/bin/env bash

if grep -qE '^\s*Defaults.*\s!authenticate' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
  echo "Disabled"
else
  echo "Enabled"
fi