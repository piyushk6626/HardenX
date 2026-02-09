#!/usr/bin/env bash

if ! systemctl list-unit-files | grep -q '^dnsmasq.service'; then
    echo "not-installed"
    exit 0
fi

if systemctl is-enabled --quiet dnsmasq; then
    echo "enabled"
else
    echo "disabled"
fi