#!/usr/bin/env bash

if ! command -v aide &>/dev/null; then
    echo "Not Installed"
    exit 0
fi

if grep -qrh 'aide' /etc/crontab /etc/cron.* /var/spool/cron/ 2>/dev/null; then
    echo "Scheduled"
else
    echo "Not Scheduled"
fi