#!/usr/bin/env bash

# This script checks for the presence of four specific auditd rules.
# It's possible for syscalls to be grouped in different ways. This script
# checks that for each combination of arch (b32/b64) and error (EACCES/EPERM),
# all required syscalls (open, openat, creat, truncate, ftruncate) are covered.

# Fetch the ruleset once to avoid repeated calls.
# Use stdbuf to prevent buffering issues in some environments.
if command -v stdbuf &>/dev/null; then
    RULES=$(stdbuf -o0 auditctl -l)
else
    RULES=$(auditctl -l)
fi

# Function to check if syscalls are covered for a given arch and error.
check_coverage() {
    local arch="$1"
    local error="$2"
    local syscalls_to_check=("open" "openat" "creat" "truncate" "ftruncate")

    # Filter rules for the specific architecture, error, and auid conditions.
    local relevant_rules
    relevant_rules=$(echo "$RULES" | grep -E -- "-a (always,exit|exit,always)" \
        | grep -- "-F arch=${arch}" \
        | grep -- "-F exit=-${error}" \
        | grep -- "-F auid>=1000" \
        | grep -E "(-F auid!=-1|-F auid!=4294967295)")

    # If no rules match the basic criteria, coverage is impossible.
    if [ -z "$relevant_rules" ]; then
        return 1
    fi

    # Check that each required syscall is present in the set of relevant rules.
    for syscall in "${syscalls_to_check[@]}"; do
        if ! echo "$relevant_rules" | grep -q -w "$syscall"; then
            return 1 # A syscall is missing.
        fi
    done

    return 0 # All syscalls were found.
}

# Use a flag to track the overall status.
present=true

# Check all four required combinations.
if ! check_coverage "b64" "EACCES"; then present=false; fi
if ! check_coverage "b32" "EACCES"; then present=false; fi
if ! check_coverage "b64" "EPERM";  then present=false; fi
if ! check_coverage "b32" "EPERM";  then present=false; fi

if [ "$present" = true ]; then
    echo "Present"
else
    echo "Absent"
fi