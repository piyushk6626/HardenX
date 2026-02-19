#!/usr/bin/env bash

if grep -qE '^\s*[^#].*\s+@@?' /etc/rsyslog.conf /etc/rsyslog.d/* 2>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi