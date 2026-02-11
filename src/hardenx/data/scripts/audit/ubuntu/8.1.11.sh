#!/usr/bin/env bash

if cat /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null | \
   grep -v '^\s*#' | \
   grep -qE '(\$ModLoad[[:space:]]+im(udp|tcp)|\$UDPServerRun|\$InputTCPServerRun|module\(load="im(udp|tcp)"\)|input\(type="im(udp|tcp)")'
then
    echo "enabled"
else
    echo "disabled"
fi