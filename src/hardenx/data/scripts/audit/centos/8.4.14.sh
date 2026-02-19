#!/bin/bash

if auditctl -l | grep -q -- "-w /etc/selinux/ -p wa"; then
    echo "true"
else
    echo "false"
fi