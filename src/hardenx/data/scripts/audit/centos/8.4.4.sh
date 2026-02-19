#!/usr/bin/env bash

# This script must be run as root to execute auditctl
if [[ $EUID -ne 0 ]]; then
   echo "disabled"
   exit 1
fi

# Get the live audit rules once to improve performance
live_rules=$(auditctl -l 2>/dev/null)
if [[ $? -ne 0 ]] || [[ -z "$live_rules" ]]; then
    echo "disabled"
    exit 1
fi

# --- Check 1: Watch rule for /etc/localtime ---
if ! echo "$live_rules" | grep -q -E -- '^-w /etc/localtime -p wa( -k |-F key=)time-change$'; then
    echo "disabled"
    exit 0
fi

# --- Check 2: 32-bit syscall rules ---
# Find a line with arch=b32 and the correct key
line32=$(echo "$live_rules" | grep -E -- '-a (always,exit|exit,always)' | grep -- '-F arch=b32' | grep -E -- '(-k |-F key=)time-change$')
# Check if that line contains all required syscalls
if [[ -z "$line32" ]] || \
   ! echo "$line32" | grep -q -w "adjtimex" || \
   ! echo "$line32" | grep -q -w "settimeofday" || \
   ! echo "$line32" | grep -q -w "clock_settime"; then
    echo "disabled"
    exit 0
fi

# --- Check 3: 64-bit syscall rules (only if on a 64-bit system) ---
if [[ "$(getconf LONG_BIT)" -eq 64 ]]; then
    # Find a line with arch=b64 and the correct key
    line64=$(echo "$live_rules" | grep -E -- '-a (always,exit|exit,always)' | grep -- '-F arch=b64' | grep -E -- '(-k |-F key=)time-change$')
    # Check if that line contains all required syscalls
    if [[ -z "$line64" ]] || \
       ! echo "$line64" | grep -q -w "adjtimex" || \
       ! echo "$line64" | grep -q -w "settimeofday" || \
       ! echo "$line64" | grep -q -w "stime" || \
       ! echo "$line64" | grep -q -w "clock_settime"; then
        echo "disabled"
        exit 0
    fi
fi

# If all checks passed
echo "enabled"
exit 0