#!/usr/bin/env bash

# Fetch the current audit rules, suppressing errors if the command fails.
rules=$(auditctl -l 2>/dev/null)

# If no rules are loaded, it's not configured.
if [ -z "$rules" ]; then
    echo "Not Configured"
    exit 0
fi

# List of required syscalls to check.
syscalls=(
    "setuid" "setgid" "setreuid" "setregid"
    "setresuid" "setresgid" "setfsuid" "setfsgid"
)

# Assume the configuration is correct until a missing rule is found.
all_rules_found=1

# Iterate over each syscall and check for corresponding 32-bit and 64-bit rules.
for syscall in "${syscalls[@]}"; do
    # Check for a 64-bit rule.
    # The rule line must contain arch=b64, the syscall name, and auid>=1000.
    # Using a pipe of greps is robust against different field orderings in the rule.
    if ! echo "$rules" | grep -- "-F arch=b64" | grep -E -- "-S.*$syscall|syscall=$syscall" | grep -q -- "-F auid>=1000"; then
        all_rules_found=0
        break
    fi

    # Check for a 32-bit rule.
    # The rule line must contain arch=b32, the syscall name, and auid>=1000.
    if ! echo "$rules" | grep -- "-F arch=b32" | grep -E -- "-S.*$syscall|syscall=$syscall" | grep -q -- "-F auid>=1000"; then
        all_rules_found=0
        break
    fi
done

# Print the final result based on whether all rules were found.
if [ "$all_rules_found" -eq 1 ]; then
    echo "Configured"
else
    echo "Not Configured"
fi