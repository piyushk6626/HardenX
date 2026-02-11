#!/bin/bash

awk -F'=' '/^\s*admin_space_left_action/ {sub(/#.*/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' /etc/audit/auditd.conf