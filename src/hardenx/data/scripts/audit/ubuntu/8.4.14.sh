#!/bin/bash

# Get the loaded auditd rules
# Redirect stderr to /dev/null to suppress errors if auditd is not running or auditctl is not found
rules=$(auditctl -l 2>/dev/null)

# Check for the presence of the first rule
rule1_present=$(echo "$rules" | grep -c -- "-w /etc/apparmor/ -p wa -k MAC-policy")

# Check for the presence of the second rule
rule2_present=$(echo "$rules" | grep -c -- "-w /etc/apparmor.d/ -p wa -k MAC-policy")

# If both rule counts are greater than or equal to 1, they are present
if [ "$rule1_present" -ge 1 ] && [ "$rule2_present" -ge 1 ]; then
    echo "Present"
else
    echo "Absent"
fi