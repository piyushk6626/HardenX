#!/bin/bash

if auditctl -l | grep -q -- "-w /usr/bin/setfacl -p wa"; then
  echo "Enabled"
else
  echo "Disabled"
fi