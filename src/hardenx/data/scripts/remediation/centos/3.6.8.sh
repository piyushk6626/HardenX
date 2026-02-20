#!/usr/bin/env bash

if [[ $# -ne 1 || "$1" != "Allow Configured" ]]; then
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    exit 1
fi

{
    touch /etc/cron.allow && \
    chown root:root /etc/cron.allow && \
    chmod 600 /etc/cron.allow && \
    rm -f /etc/cron.deny
} &>/dev/null

if [[ $? -eq 0 ]]; then
    exit 0
else
    exit 1
fi