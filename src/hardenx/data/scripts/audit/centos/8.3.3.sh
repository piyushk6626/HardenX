#!/usr/bin/env bash

grep -oP '^\s*admin_space_left_action\s*=\s*\K\S+' /etc/audit/auditd.conf