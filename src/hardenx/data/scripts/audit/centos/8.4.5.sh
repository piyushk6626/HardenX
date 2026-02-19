#!/usr/bin/env bash

rules=$(auditctl -l 2>/dev/null)

if echo "$rules" | grep -q "sethostname" && \
   echo "$rules" | grep -q "setdomainname" && \
   echo "$rules" | grep -q -- "-w /etc/issue" && \
   echo "$rules" | grep -q -- "-w /etc/issue.net" && \
   echo "$rules" | grep -q -- "-w /etc/hosts" && \
   echo "$rules" | grep -q -- "-w /etc/sysconfig/network"; then
    echo "true"
else
    echo "false"
fi