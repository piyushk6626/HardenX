#!/usr/bin/env bash

if ! systemctl list-unit-files --type=service | grep -q '^rsyslog.service'; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-enabled --quiet rsyslog.service; then
    echo "Enabled"
else
    echo "Disabled"
fi