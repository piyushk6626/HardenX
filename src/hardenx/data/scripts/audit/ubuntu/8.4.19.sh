#!/usr/bin/env bash

audit_rules=$(auditctl -l 2>/dev/null)

# Check syscalls
echo "$audit_rules" | grep -q -- "-S init_module"   || { echo "'Absent'"; exit 0; }
echo "$audit_rules" | grep -q -- "-S finit_module"  || { echo "'Absent'"; exit 0; }
echo "$audit_rules" | grep -q -- "-S delete_module" || { echo "'Absent'"; exit 0; }
echo "$audit_rules" | grep -q -- "-S create_module" || { echo "'Absent'"; exit 0; }

# Check file watches
echo "$audit_rules" | grep -q -- "-w /sbin/insmod"   || { echo "'Absent'"; exit 0; }
echo "$audit_rules" | grep -q -- "-w /sbin/rmmod"    || { echo "'Absent'"; exit 0; }
echo "$audit_rules" | grep -q -- "-w /sbin/modprobe" || { echo "'Absent'"; exit 0; }

# If all checks passed
echo "'Present'"