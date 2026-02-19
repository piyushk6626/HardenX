#!/bin/bash

if (command -v dpkg &>/dev/null && dpkg -s chrony &>/dev/null) || (command -v rpm &>/dev/null && rpm -q chrony &>/dev/null); then
  if systemctl is-enabled chronyd &>/dev/null; then
    echo "Installed and Enabled"
  else
    echo "Installed but Disabled"
  fi
else
  echo "Not Installed"
fi