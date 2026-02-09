#!/bin/bash

# Suppress output of systemctl and check only the exit code
if systemctl is-enabled snmpd &> /dev/null; then
    echo "enabled"
    exit 0
fi

# If not enabled, check if the unit file exists at all.
# 'cat' is a good way to test for existence; it fails if the unit is not found.
if systemctl cat snmpd.service &> /dev/null; then
    echo "disabled"
else
    echo "not installed"
fi