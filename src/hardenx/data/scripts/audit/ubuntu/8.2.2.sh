#!/usr/bin/env bash

enabled_status=$(systemctl is-enabled auditd)
active_status=$(systemctl is-active auditd)

echo "${enabled_status}-${active_status}"