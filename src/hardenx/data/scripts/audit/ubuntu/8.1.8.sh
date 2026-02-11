#!/bin/bash

grep -h -E '^\s*\$FileCreateMode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null | tail -n 1 | awk '{print $2}'