#!/usr/bin/env bash

sed -n 's/^\s*space_left_action\s*=\s*\(\S\+\).*/\1/p' /etc/audit/auditd.conf