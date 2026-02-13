#!/usr/bin/env bash

if [[ $EUID -ne 0 ]] || [[ "$1" != "Configured" ]]; then
    echo "false"
    exit 1
fi

if rm -f /etc/cron.deny && \
   touch /etc/cron.allow && \
   chown root:root /etc/cron.allow && \
   chmod 600 /etc/cron.allow; then
    echo "true"
else
    echo "false"
fi