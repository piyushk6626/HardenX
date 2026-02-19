#!/bin/bash

awk -F'=' '/^\s*log_group\s*=/ {
    value=$2
    sub(/#.*/, "", value)
    gsub(/^[ \t]+|[ \t]+$/, "", value)
    print value
    exit
}' /etc/audit/auditd.conf 2>/dev/null