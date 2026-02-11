#!/usr/bin/env bash

awk -F= '/^\s*log_file_mode\s*=/ {gsub(/[[:space:]]/, "", $2); print $2}' /etc/audit/auditd.conf