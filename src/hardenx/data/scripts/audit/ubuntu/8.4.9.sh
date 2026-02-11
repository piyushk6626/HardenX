#!/usr/bin/env bash

SYSCALLS=(
    "chmod" "fchmod" "fchmodat" "chown" "fchown" "fchownat" "lchown"
    "setxattr" "lsetxattr" "fsetxattr" "removexattr" "lremovexattr" "fremovexattr"
)

# Fetch the rules once to avoid multiple calls. Suppress errors.
RULES=$(auditctl -l 2>/dev/null)

# If auditctl fails or returns no rules, it's effectively disabled.
if [ -z "$RULES" ]; then
    echo "disabled"
    exit 0
fi

# Check for each syscall for both 32-bit and 64-bit architectures.
for syscall in "${SYSCALLS[@]}"; do
    # Check 64-bit rule
    if ! echo "$RULES" | grep -q -e "-F arch=b64" -e "-S ${syscall}" -e "-F auid>=1000" | grep -c -e "-F arch=b64" -e "-S ${syscall}" -e "-F auid>=1000" | grep -q 3; then
        echo "disabled"
        exit 0
    fi

    # Check 32-bit rule
    if ! echo "$RULES" | grep -q -e "-F arch=b32" -e "-S ${syscall}" -e "-F auid>=1000" | grep -c -e "-F arch=b32" -e "-S ${syscall}" -e "-F auid>=1000" | grep -q 3; then
        echo "disabled"
        exit 0
    fi
done

# If the loop completes, all required rules were found.
echo "enabled"