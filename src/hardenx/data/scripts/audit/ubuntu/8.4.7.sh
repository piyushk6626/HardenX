#!/usr/bin/env bash

# Gather all rules from the running configuration and rule files.
# Suppress errors if auditd is not running or rules files don't exist.
all_rules=$(auditctl -l 2>/dev/null; cat /etc/audit/rules.d/*.rules 2>/dev/null)

if [[ -z "$all_rules" ]]; then
    echo "false"
    exit 0
fi

# Function to check if a rule exists for a given syscall, exit code, and architecture.
# We look for lines that contain all three components.
rule_exists() {
    local syscall="$1"
    local exit_code="$2"
    local arch="$3"

    # Use grep -w to match the syscall as a whole word.
    # This prevents 'open' from matching 'openat'.
    # A single line must contain the arch, the exit code, and the syscall.
    if echo "$all_rules" | grep -q -w -- "$syscall" | grep -q "arch=${arch}" | grep -q "exit=${exit_code}"; then
        return 0 # Found
    else
        return 1 # Not found
    fi
}

syscalls=("creat" "open" "openat" "truncate" "ftruncate")

for syscall in "${syscalls[@]}"; do
    # Check for exit=-EACCES on both architectures
    if ! rule_exists "$syscall" "-EACCES" "b64"; then
        echo "false"
        exit 0
    fi
    if ! rule_exists "$syscall" "-EACCES" "b32"; then
        echo "false"
        exit 0
    fi

    # Check for exit=-EPERM on both architectures
    if ! rule_exists "$syscall" "-EPERM" "b64"; then
        echo "false"
        exit 0
    fi
    if ! rule_exists "$syscall" "-EPERM" "b32"; then
        echo "false"
        exit 0
    fi
done

# If the script has not exited yet, all required rules were found.
echo "true"