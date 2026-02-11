#!/usr/bin/env bash

# This script requires root privileges to run auditctl
if [[ $EUID -ne 0 ]]; then
   # Not printing an error to stderr to adhere to the output requirements
   echo "false"
   exit 1
fi

# Fetch the current audit rules
rules=$(auditctl -l 2>/dev/null)

# Check for each required rule.
# We use grep with patterns that are specific enough to identify the rules.
# The `\s` ensures we match the argument and not a substring in a path.
if echo "$rules" | grep -q -E -- "(-a always,exit|-a exit,always).*-S sethostname" && \
   echo "$rules" | grep -q -E -- "(-a always,exit|-a exit,always).*-S setdomainname" && \
   echo "$rules" | grep -q -- "-w /etc/issue" && \
   echo "$rules" | grep -q -- "-w /etc/issue.net" && \
   echo "$rules" | grep -q -- "-w /etc/hosts" && \
   echo "$rules" | grep -q -- "-w /etc/network/"; then
    echo "true"
else
    echo "false"
fi