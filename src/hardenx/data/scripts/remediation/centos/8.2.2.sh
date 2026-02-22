#!/bin/bash

# This script assumes it is run with sufficient privileges (e.g., as root or via sudo).
# The positional argument $1 is accepted but not used, as the action is fixed to 'enabled'.

if systemctl unmask auditd &>/dev/null && systemctl --now enable auditd &>/dev/null; then
  echo "true"
else
  echo "false"
fi