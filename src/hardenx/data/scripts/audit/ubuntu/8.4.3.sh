#!/bin/bash

if auditctl -l 2>/dev/null | grep -q -- "-w /var/log/sudo.log -p wa"; then
  echo "Enabled"
else
  echo "Disabled"
fi