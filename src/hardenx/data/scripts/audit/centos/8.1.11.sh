#!/usr/bin/env bash

if grep -q -s -E '^\s*(\$ModLoad imudp|\$UDPServerRun|\$ModLoad imtcp|\$InputTCPServerRun)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null; then
    echo "enabled"
else
    echo "disabled"
fi