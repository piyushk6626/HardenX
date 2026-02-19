#!/usr/bin/env bash

# This script checks for auditd rules for file deletion by users with auid>=1000.
# It requires coverage for both 32-bit and 64-bit syscall architectures.

# Function to check if a given set of rules covers all required syscalls.
# Arguments:
#   $1: A string containing the rules to check.
check_syscalls_covered() {
    local ruleset="$1"
    local syscall
    
    # If the ruleset for this architecture is empty, it's not configured.
    if [[ -z "$ruleset" ]]; then
        return 1
    fi
    
    for syscall in unlink unlinkat rename renameat; do
        # Use grep with -w to match the syscall as a whole word.
        # This prevents 'unlink' from matching 'unlinkat'.
        if ! echo "$ruleset" | grep -qw -- "$syscall"; then
            return 1 # A required syscall is not covered in this ruleset.
        fi
    done
    
    return 0 # All syscalls are covered.
}

# Fetch all active auditd rules. Suppress errors if auditd is not running or installed.
all_rules=$(auditctl -l 2>/dev/null)

# Filter rules for auid>=1000, separating them by architecture.
# We are looking for the specific strings '-F arch=b64' and '-F arch=b32'.
rules_64bit=$(echo "$all_rules" | grep -- "-F auid>=1000" | grep -- "-F arch=b64")
rules_32bit=$(echo "$all_rules" | grep -- "-F auid>=1000" | grep -- "-F arch=b32")

# Check if both 32-bit and 64-bit rulesets cover all required syscalls.
if check_syscalls_covered "$rules_64bit" && check_syscalls_covered "$rules_32bit"; then
    echo "Configured"
else
    echo "Not Configured"
fi