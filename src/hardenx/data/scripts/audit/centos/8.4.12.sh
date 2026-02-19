#!/bin/bash

rules=$(auditctl -l 2>/dev/null)

if echo "$rules" | grep -q -- "-w /var/log/faillog -p wa" && \
   echo "$rules" | grep -q -- "-w /var/log/lastlog -p wa" && \
   echo "$rules" | grep -q -- "-w /var/log/tallylog -p wa"; then
    echo "Present"
else
    echo "Not Present"
fi