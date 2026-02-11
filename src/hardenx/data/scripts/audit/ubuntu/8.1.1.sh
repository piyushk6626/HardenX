#!/bin/bash

if systemctl is-enabled --quiet systemd-journald && systemctl is-active --quiet systemd-journald; then
    echo "Enabled and Active"
else
    echo "Not Enabled or Inactive"
fi