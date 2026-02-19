#!/bin/bash
grep -oP '^\s*max_log_file\s*=\s*\K\d+' /etc/audit/auditd.conf