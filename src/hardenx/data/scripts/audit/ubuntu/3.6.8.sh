#!/usr/bin/env bash

CRON_ALLOW="/etc/cron.allow"
CRON_DENY="/etc/cron.deny"

if [ -f "$CRON_ALLOW" ] && \
   [ "$(stat -c "%U" "$CRON_ALLOW")" == "root" ] && \
   [ "$(stat -c "%G" "$CRON_ALLOW")" == "root" ] && \
   [ "$(stat -c "%a" "$CRON_ALLOW")" == "600" ] && \
   [ ! -f "$CRON_DENY" ]; then
    echo "Configured"
else
    echo "Not Configured"
fi