#!/usr/bin/env bash

awk -F= '/^max_log_file_action/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' /etc/audit/auditd.conf