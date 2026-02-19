#!/usr/bin/env bash

if [[ "$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)" == "1" ]] || \
   [[ "$(sysctl -n net.ipv6.conf.default.disable_ipv6 2>/dev/null)" == "1" ]] || \
   grep -q -w "ipv6.disable=1" /proc/cmdline 2>/dev/null; then
    echo "Disabled"
else
    echo "Enabled"
fi