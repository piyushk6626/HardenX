#!/bin/bash

is_enabled=$(systemctl is-enabled cron.service 2>/dev/null || echo "not-found")
is_active=$(systemctl is-active cron.service 2>/dev/null || echo "not-found")

echo "${is_enabled}-${is_active}"