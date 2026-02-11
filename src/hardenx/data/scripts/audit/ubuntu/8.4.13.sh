#!/usr/bin/env bash

rules=$(auditctl -l 2>/dev/null)
key_pattern="-k delete"
arch64_pattern="-F arch=b64"
arch32_pattern="-F arch=b32"

# Filter rules once for each architecture that contains the delete key
rules_b64=$(echo "$rules" | grep -- "$arch64_pattern" | grep -- "$key_pattern")
rules_b32=$(echo "$rules" | grep -- "$arch32_pattern" | grep -- "$key_pattern")

# Check if we have any relevant rules to begin with
if [ -z "$rules_b64" ] || [ -z "$rules_b32" ]; then
    echo "false"
    exit 0
fi

for syscall in unlink unlinkat rename renameat; do
    # The regex checks for the syscall as a whole word, potentially preceded or followed by a comma
    # This correctly handles listings like "-S open,unlink,close"
    syscall_pattern="-S.*(\b|,)${syscall}(\b|,)"

    if ! echo "$rules_b64" | grep -qE -- "$syscall_pattern"; then
        echo "false"
        exit 0
    fi

    if ! echo "$rules_b32" | grep -qE -- "$syscall_pattern"; then
        echo "false"
        exit 0
    fi
done

echo "true"