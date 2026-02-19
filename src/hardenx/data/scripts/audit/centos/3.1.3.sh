#!/usr/bin/env bash

if status=$(systemctl is-enabled dhcpd 2>/dev/null); then
    echo "$status"
else
    echo 'not installed'
fi