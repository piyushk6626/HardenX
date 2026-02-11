#!/bin/bash

sed -n 's/^[[:space:]]*log_group[[:space:]]*=[[:space:]]*//p' /etc/audit/auditd.conf