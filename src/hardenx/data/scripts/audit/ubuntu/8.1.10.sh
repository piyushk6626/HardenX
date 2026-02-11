#!/usr/bin/env bash

grep -E -h '^[[:space:]]*\*.\*\s+[@]{1,2}' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null | head -n 1
