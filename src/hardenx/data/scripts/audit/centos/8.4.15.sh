#!/usr/bin/env bash

output=$(auditctl -l 2>/dev/null)
found_b64=0
found_b32=0

# Check for the simple '-w' rule which covers both architectures on 64-bit systems
if echo "$output" | grep -q -- "-w /usr/bin/chcon -p x"; then
    echo "Present"
    exit 0
fi

# If '-w' rule is not found, check for explicit arch-specific rules
if echo "$output" | grep -E "(-a always,exit|-A always,exit)" | grep -E "arch=b64" | grep -E "path=/usr/bin/chcon" | grep -q -E "(perm=x|S( )*execve)"; then
    found_b64=1
fi

if echo "$output" | grep -E "(-a always,exit|-A always,exit)" | grep -E "arch=b32" | grep -E "path=/usr/bin/chcon" | grep -q -E "(perm=x|S( )*execve)"; then
    found_b32=1
fi

if [[ $found_b64 -eq 1 && $found_b32 -eq 1 ]]; then
    echo "Present"
else
    echo "Absent"
fi