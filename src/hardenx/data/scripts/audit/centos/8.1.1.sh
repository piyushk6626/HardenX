#!/bin/bash

if systemctl is-enabled --quiet systemd-journald && systemctl is-active --quiet systemd-journald; then
    echo "enabled"
else
    echo "disabled"
fi