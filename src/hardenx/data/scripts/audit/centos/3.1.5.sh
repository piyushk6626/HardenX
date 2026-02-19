#!/bin/bash

if rpm -q dnsmasq &>/dev/null; then
    systemctl is-enabled dnsmasq
else
    echo "Not Installed"
fi