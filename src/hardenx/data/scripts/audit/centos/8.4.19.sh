#!/usr/bin/env bash

# This script checks for the presence of specific auditd rules for kernel module loading.
# It requires root privileges to run auditctl.

# Fetch the current auditd rules once to avoid multiple calls.
RULES=$(auditctl -l 2>/dev/null)

# Check for the three '-w' rules using grep.
# The '--' ensures that rule strings starting with '-' are not treated as options.
check_insmod() {
    echo "$RULES" | grep -q -- "-w /sbin/insmod -p x -k modules"
}

check_rmmod() {
    echo "$RULES" | grep -q -- "-w /sbin/rmmod -p x -k modules"
}

check_modprobe() {
    echo "$RULES" | grep -q -- "-w /sbin/modprobe -p x -k modules"
}

# Check for the '-a' rule. This is more complex as the order of fields isn't guaranteed.
# We find a line that contains all the required components.
# The regex '-F arch=b(32|64)' handles both 32-bit and 64-bit architectures.
check_syscall() {
    echo "$RULES" | grep -- "-a always,exit" | \
                    grep -- "-S init_module,delete_module" | \
                    grep -- "-k modules" | \
                    grep -qE -- "-F arch=b(32|64)"
}

# Execute all checks. If any check fails, the 'if' condition will be false.
if check_insmod && check_rmmod && check_modprobe && check_syscall; then
    echo "present"
else
    echo "absent"
fi